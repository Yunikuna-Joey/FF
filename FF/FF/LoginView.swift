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
            
            // the action is the if statement checking
            Button(action: {
                // success login functionality
                if self.username == "your_username" && self.password == "your_password" {
                    self.alertMsg = "Login Success!"
                    self.activeAlert = true
                }
                // failed login functionality
                else {
                    self.alertMsg = "Login Error!"
                    self.activeAlert = true
                }
            }) {
                Text("Login")
                    // text color
                    .foregroundStyle(.white)
                    .padding()
                    // size of the button customized
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            // this is the dyanmic creation of the dialogue box
            .alert(isPresented: $activeAlert) {
                // bolded title
                Alert(title: Text("Login"),
                // status message
                message: Text(alertMsg),
                // dynamically create the OK button 
                dismissButton: .default(Text("OK")))
            }
        }
        // apply space from the top
        .padding(.top, 100)
    }
    
}

#Preview {
    LoginView()
}
