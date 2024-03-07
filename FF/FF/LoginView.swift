//
//  LoginView.swift
//  FF
//
//

import SwiftUI

struct LoginView: View {
    // @state is for variables within one specfic view
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var activeAlert: Bool = false
    @State private var alertMsg: String = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                // padding is to provide space around an UI element
                .padding()
                .background(Color.gray.opacity(0.33))
                .cornerRadius(5)
                // apply horizontal padding of 50 points
                .padding(.horizontal, 50)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.33))
                .cornerRadius(5)
                .padding(.horizontal, 50)
        }
    }
    
}

#Preview {
    LoginView()
}
