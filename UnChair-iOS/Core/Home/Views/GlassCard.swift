//
//  GlassCard.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 4/5/25.
//

import SwiftUI


struct GlassCard<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
      .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
  }
}

struct CustomBlurView: UIViewRepresentable{
    var effect: UIBlurEffect.Style
    var onChange: (UIVisualEffectView) -> ()
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            onChange(uiView)
        }
    }
}
