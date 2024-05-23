//
//  BackgroundView.swift
//  FF
//
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            // Base layer
//            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0.0)]), startPoint: .top, endPoint: .bottom)
            
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)).opacity(0.7), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).opacity(0.7), Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)).opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
           
        }
//        .background(
//            ZStack {
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5), Color.white.opacity(0.3)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .edgesIgnoringSafeArea(.all)
//                .blur(radius: 50)
//            }
//        )
    }
}

#Preview {
    BackgroundView()
}
