//
//  FFApp.swift
//  FF
//
//  Created by Joey Truong on 3/7/24.
//

import SwiftUI
import Firebase

@main
struct FFApp: App {
    // Determines an authenticated view
    @StateObject var viewModel = AuthView()
    @StateObject var statusProcess = StatusProcessView()
    @StateObject var followManager = FollowingManager()
    @StateObject var planManager = PlanManager()
    @StateObject var messageManager = MessageManager()
    
    // configure firebase within our app
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // create an environment object for the 
                .environmentObject(viewModel)
                .environmentObject(statusProcess)
                .environmentObject(followManager)
                .environmentObject(planManager)
                .environmentObject(messageManager)
        }
    }
}
