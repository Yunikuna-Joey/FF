//
//  ProfileView.swift
//  FF
//
//

import SwiftUI

struct ProfileView: View {
    // CONSTANTS
    @EnvironmentObject var viewModel: AuthView
    @State private var current: Tab = .status
    
    // iterate through the different tabs
    func currSelection(_ tab:Tab) -> Bool {
        return current == tab
    }
    
    // create cases for tabs
    enum Tab {
        case status
        case images
        case others
    }
    
    // [test] dynamic user information loading
    let username = "Womp Womp"
    let value1 = 25
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topTrailing) {
                VStack {
                    // Cover Photo
                    Image("Car")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: screenSize.height * 0.30)
                        .clipped()
                    
                    // profile picture
                    Image("car2")
                        .resizable()
                        .frame(width: 200, height: 150)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    // [play with this offset value]
                        .offset(y: -100)
                    
                    // pushes the cover photo AND profile picture
                    Spacer()
                    
                    // Stack for username
                    HStack {
                        Text("@username")
                            .font(.headline)
                        // [play with this offset value]
                    }
                    .offset(y: -screenSize.height * 0.12)
                    
                    // HStack for user statistics
                    HStack(spacing: screenSize.width * 0.15) {
                        // category 1
                        VStack {
                            Text("Check-Ins")
                                .font(.headline)
                            Text("\(value1)")
                        }
                        // category 2
                        VStack {
                            Text("Followers")
                                .font(.headline)
                            Text("\(value1)")
                        }
                        // category 3
                        VStack {
                            Text("Following")
                                .font(.headline)
                            Text("\(value1)")
                        }
                    }
                    .offset(y: -screenSize.height * 0.10)
                    
                    // HStack for clickable icons to switch between the different tabs
                    HStack(spacing: screenSize.width * 0.25) {
                        // Button #1
                        Button(action: {
                            current = .status
                        }) {
                            Image(systemName: "person.fill")
                                .padding()
                                .foregroundStyle(Color.blue)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .offset(y: 20)
                                        .foregroundStyle(currSelection(.status) ? .blue : .clear)
                                )
                        }
                        
                        // Button #2
                        Button(action: {
                            current = .images
                        }) {
                            Image(systemName: "photo.fill")
                                .padding()
                                .foregroundStyle(Color.blue)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .offset(y: 20)
                                        .foregroundStyle(currSelection(.images) ? .blue : .clear)
                                )
                        }
                        
                        // Button #3
                        Button(action: {
                            current = .others
                        }) {
                            Image(systemName: "calendar")
                                .padding()
                                .foregroundStyle(Color.blue)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .offset(y: 20)
                                        .foregroundStyle(currSelection(.others) ? .blue : .clear)
                                )
                        }
                    }
                    .foregroundStyle(Color.blue)
                    .offset(y: -screenSize.height * 0.10)
                    
                    // VStack for the actual different tab views
                    VStack {
                        switch current {
                        case .status:
                            ProfileView1()
                        case .images:
                            ProfileView2()
                        case .others:
                            ProfileView3()
                        }
                    }
                    .offset(y: -screenSize.height * 0.10)
                    .padding(.horizontal, 5)
                    .frame(minHeight: screenSize.height * 0.45)
                } // end of VStack
                
                VStack {
                    Button(action: {
                        print("Settings here for sign out and such")
                    }) {
                        Image(systemName: "gearshape.fill")
                            .padding()
                            .foregroundStyle(Color.blue)
                    }
                }
                .padding(.top, screenSize.height * 0.30) // Adjust top padding as needed
                .padding(.trailing, screenSize.width * 0.01) // Adjust trailing padding as needed
            } // end of ZStack
        }
        
    } // end of body here
}

#Preview {
    ProfileView()
}
