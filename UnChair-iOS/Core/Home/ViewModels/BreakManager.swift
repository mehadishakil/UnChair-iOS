import Foundation
import Combine

class BreakManager: ObservableObject {
    static let shared = BreakManager()
    
    @Published var sedentaryTime: TimeInterval = 0
    @Published var lastBreakTime: Date?
    @Published var isOnBreak: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?
    private var notificationManager = NotificationManager.shared
    
    private init() {
        setupNotifications()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        Task {
            do {
                let granted = try await notificationManager.requestPermission()
                if granted {
                    print("Notification permission granted")
                }
            } catch {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
        
        // Listen for break notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBreakNotification),
            name: NSNotification.Name("UserTookBreak"),
            object: nil
        )
    }
    
    // MARK: - Break Management
    
    func startTracking(focusedDuration: TimeDuration, activeHours: (start: Date, end: Date)) {
        // Cancel any existing timer
        stopTracking()
        
        // Set start time to now or last break time
        startTime = lastBreakTime ?? Date()
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateSedentaryTime()
        }
        
        // Schedule the next break notification
        if let startTime = startTime {
            let timeUntilBreak = focusedDuration.totalMinutes * 60
            notificationManager.scheduleBreakNotification(
                after: timeUntilBreak,
                focusedDuration: focusedDuration,
                lastBreakTime: startTime
            )
        }
        
        // Schedule daily break notifications
        notificationManager.scheduleDailyBreakNotifications(
            focusedDuration: focusedDuration,
            activeHours: activeHours
        )
    }
    
    func stopTracking() {
        timer?.invalidate()
        timer = nil
        notificationManager.cancelAllPendingNotifications()
    }
    
    func takeBreak() {
        isOnBreak = true
        lastBreakTime = Date()
        stopTracking()
        
        // Post notification that user took a break
        NotificationCenter.default.post(name: NSNotification.Name("UserTookBreak"), object: nil)
    }
    
    func resumeFromBreak(focusedDuration: TimeDuration, activeHours: (start: Date, end: Date)) {
        isOnBreak = false
        startTracking(focusedDuration: focusedDuration, activeHours: activeHours)
    }
    
    // MARK: - Private Methods
    
    private func updateSedentaryTime() {
        guard let startTime = startTime else { return }
        sedentaryTime = Date().timeIntervalSince(startTime)
    }
    
    @objc private func handleBreakNotification() {
        takeBreak()
    }
} 