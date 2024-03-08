//
//  ContentView.swift
//  FF
//
//  This is going to be the home page..

import SwiftUI

struct ContentView: View {
    var body: some View {
        // This layer will hold our nav menu
        ZStack {
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
}

#Preview {
    ContentView()
}
