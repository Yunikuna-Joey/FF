//
//  RegisterView.swift
//  FF
//
//

import SwiftUI

struct RegisterView: View {
    // CONSTANTS
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var error: Bool = false
    @State private var cont: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                
                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                
                // Essentially an 'Error Field' implementation
                if error {
                    Text("Error: That email has already been used")
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                Button(action: {
                    if email == "123" {
                        error = true
                    }
                    
                    else {
                        cont = true
                    }
                    
                }) {
                    Text("Continue")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 25)
                }
                .navigationDestination(isPresented: $cont) {
                    RegisterView2()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
