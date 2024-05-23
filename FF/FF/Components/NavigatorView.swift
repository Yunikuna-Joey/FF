//
//  OverallView.swift
//  FF
//
//  Created by Joey Truong on 3/15/24.
//

import SwiftUI

struct NavigatorView: View {
    @State private var currentTabIndex = 0
    @State private var isStatusPosted = false
    
    init() {
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.2 // Set the opacity
        
        appearance.backgroundEffect = blurEffect // Apply the blur effect
        appearance.backgroundColor = .clear // Clear background color
        appearance.shadowImage = UIImage() // Remove the default shadow
        appearance.shadowColor = nil // Remove shadow color
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        // nav menu with all of the pages [start: home, end: profile]
        TabView (selection: $currentTabIndex) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                .background(
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)).opacity(0.7), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).opacity(0.7), Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)).opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .edgesIgnoringSafeArea(.all)
                    }
                )
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
                .tag(1)
            
            // with this set-up, the CheckinView only returns 1 view at a time
            // previously, set up multiple vstack, hstacks sepearately,,,
            // now they are all within 1 cumulative vstack
            CheckinView(currentTabIndex: $currentTabIndex)
                .tabItem {
                    Image(systemName: "checkmark.gobackward")
                    Text("Check In")
                }
                .tag(2)
            
            MessageView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chats")
                }
                .tag(3)
  
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(4)
        }
    }
}

#Preview {
    NavigatorView()
}
