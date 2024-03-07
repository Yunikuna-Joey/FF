//
//  LoginView.swift
//  FF
//
//
// seems like there can be conflicting behaviors... alert box overrules view redirection

import SwiftUI

struct LoginView: View {
    // @state is for variables within one specfic view
    @State private var username: String = ""
    @State private var password: String = ""
    
    // This is to keep track of user status,,, either logged in or not
    @State private var status: Bool = false
    
    var body: some View {
        // Navigation Stack provides a storyline within our elements.. indicating that another screen will be loaded
        NavigationStack {
            VStack {
                TextField("Username", text: $username)
                    // padding is to provide space around an UI element
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    // apply horizontal padding of 50 points
                    .padding(.horizontal, 50)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                
                // the action is the if statement checking
                Button(action: {
                    // success login functionality
                    if self.username == "123" && self.password == "123" {
                        self.status = true
                    }
                    // failed login functionality
                    else {
        
                        self.status = false
                    }
                }) {
                    Text("Login")
                        // text color
                        .foregroundStyle(.white)
                        .padding()
                        // size of the button customized
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .navigationDestination(isPresented: $status) {
                    ContentView()
                }
            } // end of VStack here
            
            
            .navigationTitle("Welcome to FF")
            
            
            
        } // end of NavigationStack here
        
    } // end of body here
    
} // end of structure here

#Preview {
    LoginView()
}
