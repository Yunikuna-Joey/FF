//
//  OverallView.swift
//  FF
//
//  Created by Joey Truong on 3/15/24.
//

import SwiftUI

struct NavigatorView: View {
    var body: some View {
        // nav menu with all of the pages [start: home, end: profile]
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
            // with this set-up, the CheckinView only returns 1 view at a time
            // previously, set up multiple vstack, hstacks sepearately,,,
            // now they are all within 1 cumulative vstack
            CheckinView()
                .tabItem {
                    Image(systemName: "checkmark.gobackward")
                    Text("Check In")
                }
            MessageView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chats")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    NavigatorView()
}
