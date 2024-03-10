//
//  ContentView.swift
//  FF
//
//  This is going to be the home page..

import SwiftUI

struct ContentView: View {
    var body: some View {
        // This layer will hold our nav menu
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
    ContentView()
}
