//
//  LoginView.swift
//  FF
//
//

import SwiftUI

struct LoginView: View {
    // This will help maintain session [session handling]
    @EnvironmentObject var viewModel: AuthView
    
    // @state is for variables within one specfic view
    @State private var email: String = ""
    @State private var password: String = ""
    
    // This is to keep track of user status,,, either logged in or not
    @State private var status: Bool = false
    @State private var register: Bool = false
    
    @State private var redirect: Bool = false
    @State private var errorFlag: Bool = false
    
    var body: some View {
        // Navigation Stack provides a storyline within our elements.. indicating that another screen will be loaded
        NavigationStack {
            VStack {
                // $variable_name binds the view to the variable when a user interacts with it
                TextField("Email", text: $email)
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
                
                HStack {
                    Button(action: {
                        // shift the value into 1 meaning that we have executed the button functionality
                        self.register = true
                    }) {
                        Text("Register")
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 140, height: 50)
                            .background(Color.gray)
                            .cornerRadius(10)
                       
                    }
                    .navigationDestination(isPresented: $register) {
                        RegisterView()
                    }
                    
                    // Login logic here
                    Button(action: {
                        // new logic here
                        Task {
                            self.errorFlag = try await viewModel.signIn(withEmail: email, password: password)
                        }
                    }) {
                        Text("Login")
                            // text color
                            .foregroundStyle(.white)
                            .padding()
                            // size of the button customized
                            .frame(width: 145, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .disabled(!validForm)
                            .opacity(validForm ? 1.0 : 0.5)
                            
                    }
                    .navigationDestination(isPresented: $status) {
                        ContentView()
                            // This removes the back button from the screen when redirected from the login view
                            .navigationBarBackButtonHidden(true)
                    }
                } // end of hstack
                
                
                // error message here
                Text("You have entered the wrong email or password!")
                    .foregroundStyle(Color.red)
                    .opacity(errorFlag ? 1 : 0)
                
                
            } // end of VStack here
            
            .navigationTitle("Welcome to FF")
            
            
            
        } // end of NavigationStack here
        
    } // end of body here
    
} // end of structure here

extension LoginView: AuthenticationFormProtocol {
    var validForm: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count >= 8
    }
}

#Preview {
    LoginView()
}
