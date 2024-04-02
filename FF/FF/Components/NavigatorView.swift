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
    
    var body: some View {
        // nav menu with all of the pages [start: home, end: profile]
        TabView (selection: $currentTabIndex) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
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
