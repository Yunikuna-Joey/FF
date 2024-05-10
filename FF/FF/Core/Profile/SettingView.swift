//
//  SettingView.swift
//  FF
//
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var viewModel: AuthView
    
    var body: some View {
        Button(action: {
            viewModel.signOut()
            print("Settings page sign out button")
        }) {
            HStack {
                Text("Sign out!")
                    .foregroundStyle(Color.black)
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(Color.red)
                    .padding()
            }
        }
        
//        ScrollViewWithDelegate(scrolledToTop: $scrolledToTop, scrollProxy: $scrollProxy, showsIndicators: false) {
//
//            
//            LazyVStack {
//                ForEach(0..<50) { index in
//                    Text("Row \(index)")
//                        .frame(height: 50)
//                }
//            }
//            .frame(maxWidth: .infinity)
//        }
//        .onChange(of: scrolledToTop) {
//            if scrolledToTop {
//                print("Top of ScrollView reached")
//                // Reset scrolledToTop to false to detect next scroll to top
//                self.scrolledToTop = false
//            }
//        }
//        .defaultScrollAnchor(.bottom)
    }
}

#Preview {
    SettingView()
}
