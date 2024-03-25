//
//  ContentView.swift
//  FF
//
//  This is going to be the home page..

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthView
    
    var body: some View {
        Group {
            // the case where the user is logged in (AKA the session is active)
            if viewModel.userSession != nil {
                NavigatorView()
            }
            
            else {
                LoginView()
            }
        }
    }
}


#Preview {
    ContentView()
}
