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
                    BackgroundView()
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
                .background(
                    BackgroundView()
                )
            
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
