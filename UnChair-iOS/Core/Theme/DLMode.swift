//import SwiftUI
//
//
//struct DLMode: View {
//    @Binding var appearanceMode: AppearanceMode
//    @Binding var colorScheme: ColorScheme?
//
//    var body: some View {
//        VStack(spacing: 20) {
//            HStack(alignment: .center) {
//                Text("Appearance")
//                    .font(.title3.bold())
//            }
//            .padding()
//
//            HStack(spacing: 40){
//                Button {
//                    appearanceMode = .light
//                    colorScheme = .light
//                } label: {
//                    UIButton(mode: .light, currentMode: $appearanceMode, Rbg: .LB, Rbgi: .LBI, ibg: .white)
//                }
//                .tint(.primary)
//                Button {
//                    appearanceMode = .dark
//                    colorScheme = .dark
//                } label: {
//                    UIButton(mode: .dark, currentMode: $appearanceMode, Rbg: .DB, Rbgi: .DBI, ibg: .black)
//                }
//                .tint(.primary)
//                
//                
//                ZStack {
//                    UIButton(mode: .system, currentMode: $appearanceMode, Rbg: .LB, Rbgi: .LBI, ibg: .white)
//                    UIButton(mode: .system, currentMode: $appearanceMode, Rbg: .DB, Rbgi: .DBI, ibg: .black)
//                        .mask{
//                            RoundedRectangle(cornerRadius: 10)
//                                .frame(width: 50, height: 200)
//                                .offset(x: -24)
//                        }
//                }
//                .onTapGesture {
//                    appearanceMode = .system
//                    colorScheme = nil
//                }
//                
//                
//            }
//            .padding(.horizontal, 8)
//            .preferredColorScheme(colorScheme)
//
//            Spacer()
//        }
//        .cornerRadius(30)
//        .preferredColorScheme(colorScheme)
//    }
//}
//
//
//
//#Preview {
//    DLMode(appearanceMode: .constant(.dark), colorScheme: .constant(.dark))
//}
//
//enum AppearanceMode {
//    case dark, light, system
//}
//
//struct UIButton: View {
//    var mode : AppearanceMode
//    @Binding var currentMode : AppearanceMode
//    var Rbg : Color
//    var Rbgi : Color
//    var ibg : Color
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            VStack{
//                Circle().frame(width: 20, height: 20)
//                RoundedRectangle(cornerRadius: 10)
//                    .frame(width: 49, height: 6)
//                VStack(spacing: 5) {
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: 38, height: 6)
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: 38, height: 6)
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: 38, height: 6)
//                }
//                .frame(width: 55, height: 50)
//                .background(ibg, in:RoundedRectangle(cornerRadius: 5))
//            }
//            .foregroundStyle(Rbgi)
//            .padding(8)
//            .overlay(content: {
//                if currentMode == mode {
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(lineWidth: 2)
//                        .padding(-3)
//                }
//            })
//            .background(Rbg, in: RoundedRectangle(cornerRadius: 7))
//            Text(String(describing: mode).capitalized)
//                .foregroundStyle(currentMode == mode ? .selectedT : .T)
//                .font(.system(size: 15))
//                .frame(width: 80, height: 25)
//                .background(currentMode == mode ? .BL : .buttonBG, in: RoundedRectangle(cornerRadius: 10))
//            
//        }
//        .scaleEffect(currentMode == mode ? 1.1 : 0.9)
//        .animation(.default, value: currentMode)
//    }
//}



import SwiftUI

struct DLMode: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center) {
                Text("Appearance")
                    .font(.title3.bold())
            }
            .padding()

            HStack(spacing: 40) {
                Button {
                    themeManager.selectedTheme = .light
                } label: {
                    UIButton(mode: .light, currentMode: $themeManager.selectedTheme)
                }
                
                Button {
                    themeManager.selectedTheme = .dark
                } label: {
                    UIButton(mode: .dark, currentMode: $themeManager.selectedTheme)
                }
                
                Button {
                    themeManager.selectedTheme = .system
                } label: {
                    ZStack {
                        UIButton(mode: .system, currentMode: $themeManager.selectedTheme)
                    }
                }
            }
            .padding(.horizontal, 8)

            Spacer()
        }
        .preferredColorScheme(themeManager.applyTheme())
        .cornerRadius(30)
    }
}

struct UIButton: View {
    var mode: Theme
    @Binding var currentMode: Theme
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Circle().frame(width: 20, height: 20)
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 49, height: 6)
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 38, height: 6)
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 38, height: 6)
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 38, height: 6)
                }
                .frame(width: 55, height: 50)
                .background(mode == .dark ? Color.black : .white, in: RoundedRectangle(cornerRadius: 5))
            }
            .foregroundStyle(mode == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1))
            .padding(8)
            .overlay(content: {
                if currentMode == mode {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 2)
                        .padding(-3)
                }
            })
            .background(mode == .dark ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 7))
            
            Text(String(describing: mode).capitalized)
                .foregroundStyle(currentMode == mode ? .blue : .gray)
                .font(.system(size: 15))
                .frame(width: 80, height: 25)
                .background(currentMode == mode ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        }
        .scaleEffect(currentMode == mode ? 1.1 : 0.9)
        .animation(.default, value: currentMode)
    }
}
