//
//  OverallView.swift
//  FF
//
//  Created by Joey Truong on 3/15/24.
//

import SwiftUI

//struct CustomTabBar: View {
//    @Binding var currentTabIndex: Int
//    
//    var body: some View {
//        HStack(spacing: 20) {
//            Spacer()
//            TabBarItem(icon: "house.fill", tabIndex: 0, currentTabIndex: $currentTabIndex)
//            Spacer()
//            TabBarItem(icon: "magnifyingglass", tabIndex: 1, currentTabIndex: $currentTabIndex)
//            Spacer()
//            TabBarItem(icon: "checkmark.gobackward", tabIndex: 2, currentTabIndex: $currentTabIndex)
//            Spacer()
//            TabBarItem(icon: "message.fill", tabIndex: 3, currentTabIndex: $currentTabIndex)
//            Spacer()
//            TabBarItem(icon: "person.crop.circle", tabIndex: 4, currentTabIndex: $currentTabIndex)
//            Spacer()
//        }
//    }
//}
//
//struct TabBarItem: View {
//    let icon: String
//    let tabIndex: Int
//    @Binding var currentTabIndex: Int
//    
//    var body: some View {
//        Button(action: {
//            currentTabIndex = tabIndex
//        }) {
//            Image(systemName: icon)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25)
//                .foregroundColor(currentTabIndex == tabIndex ? .blue : .gray)
//        }
//        .padding(.top, 5)
//    }
//}

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
    
    //    var body: some View {
    //        VStack {
    //            // Main content views
    //            ZStack {
    //                switch currentTabIndex {
    //                case 0:
    //                    HomeView()
    //                case 1:
    //                    SearchView()
    //                case 2:
    //                    CheckinView(currentTabIndex: $currentTabIndex)
    //                case 3:
    //                    MessageView()
    //                case 4:
    //                    ProfileView()
    //                default:
    //                    HomeView()
    //                }
    //            }
    //            .frame(maxWidth: .infinity, maxHeight: .infinity)
    //
    //            // Custom tab bar
    //            CustomTabBar(currentTabIndex: $currentTabIndex)
    //        }
    //    }
}

#Preview {
    NavigatorView()
}
