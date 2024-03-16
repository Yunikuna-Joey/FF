//
//  FFApp.swift
//  FF
//
//  Created by Joey Truong on 3/7/24.
//

import SwiftUI

@main
struct FFApp: App {
    @StateObject var viewModel = AuthView()
    var body: some Scene {
        WindowGroup {
            ContentView()
                // create an environment object for the 
                .environmentObject(viewModel)
        }
    }
}
