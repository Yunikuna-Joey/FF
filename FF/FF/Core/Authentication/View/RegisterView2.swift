//
//  RegisterView2.swift
//  FF
//
//

import SwiftUI

struct RegisterView2: View {
    // CONSTANTS
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmation: String = ""
    @State private var email: String = ""
    
    @State private var status: Bool = false
    @State private var error: Bool = false
    @State private var error2: Bool = false
    @State private var error3: Bool = false
    
    @EnvironmentObject var viewModel: AuthView
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                
                SecureField("Confirm Password", text: $confirmation)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                
                // matching password
                if error {
                    Text("Error: Passwords do not match!")
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                // password length checker
                else if error2 {
                    Text("Error: Password does not meet the minimum length requirements")
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                // username checker [not case-sensitive] so Nani == nani [the name itself can no longer be used]
                else if error3 {
                    Text("Error: That username has already been taken!")
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                Button(action: {
                    if self.password != self.confirmation {
                        self.error2 = false
                        self.error = true
                    }
                    
                    else if confirmation.count < 8 || password.count < 8 {
                        self.error = false
                        self.error2 = true
                    }
                    
                    else if username.lowercased() == "nani" {
                        self.error = false
                        self.error2 = false
                        self.error3 = true
                    }
                    
                    else {
                        self.error = false
                        self.error2 = false
                        self.status = true
                        
//                        Task {
//                            // edit here
//                            try await viewModel.createUser(withEmail: email, password: password, fullname: username)
//                        }
                    }
                    
                }) {
                    Text("Register!")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 25)
                }
                .navigationDestination(isPresented: $status) {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    RegisterView2()
}
