//
//  ContentView.swift
//  FF
//
//  This is going to be the home page..

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(.gray)
                .ignoresSafeArea(.all)
            
            VStack {
                Text("Hello World!")
            }
        }
        
    }
}

#Preview {
    ContentView()
}
