//
//  RegisterView.swift
//  FF
//
//

import SwiftUI

struct RegisterView: View {
    // CONSTANTS
    @EnvironmentObject var viewModel: AuthView
    
    // [Text Fields]
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = "" 
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmation: String = ""
    
    // error flags
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmationError: String?
    
    // Redirection variable
    @State private var success = false
    @State private var registrationError: String?

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
                
                TextField("Username", text: $username)
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
                    // test this two parameter style...
                    .onChange(of: email) {_, newChar in
                        emailError = validateEmail(newChar)
                    }
                
                // error field for the email field
                if let emailError = emailError {
                    Text(emailError)
                        .foregroundStyle(Color.red)
                        .padding(.horizontal)
                }
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                    .onChange(of: password) { _, newChar in
                        passwordError = validatePassword(newChar)
                    }
                
                // Error field for the password field
                if let passwordError = passwordError {
                    Text(passwordError)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                SecureField("Confirm Password", text: $confirmation)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                    .onChange(of: confirmation) { _, newChar in
                        confirmationError = validateConfirmation(newChar)
                    }
                
                // Error field for the confirmation field
                if let confirmationError = confirmationError {
                    Text(confirmationError)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                
                Button(action: {
                    print("Triggered register button")
                    print(password == confirmation)
                    
                    Task {
                        // edit here
                        do {
                            if !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !username.isEmpty && !password.isEmpty && !confirmation.isEmpty {
                                
                                try await viewModel.createUser(withEmail: email, password: password, firstName: firstName, lastName: lastName, username: username)
                                success = true
                            }
                        }
                        catch {
                            registrationError = "Registration Failed: \(error.localizedDescription)"
                            print("This is the registrationError \(error)")
                        }
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
                .navigationDestination(isPresented: $success) {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }
                
                // registration error if any
                if let error = registrationError {
                    Text(error)
                        .foregroundStyle(Color.red)
                        .padding()
                }

            }
        }
    }
    
    // ********* HELPER FUNCTIONS *********
    // on key input, we are checking for the correct email format
    private func validateEmail(_ email: String) -> String? {
        // Check email format to be valid
        if !email.isValidEmail {
            return "Invalid Email"
        }
        
        return nil
    }
    
    // validate password length
    private func validatePassword(_ password: String) -> String? {
        // Uppercase functionality
        if !password.contains(where: { $0.isUppercase }) {
            return "Password must contain at least one uppercase letter!"
        }
        
        // Symbol functionality
        let symbols = "!@#$%^&*()_+\\-=[]{};':\"|,.<>/?"
        if !password.contains(where: { symbols.contains($0) }) {
            return "Password must contain at least one symbol!"
        }
        
        // password length validate
        if password.count < 8 {
            return "Password must be at least 8 characters long!"
        }
        
        // digit validation
        if !password.contains(where: {$0.isNumber }) {
            return "Password must contain at least one digit!"
        }
    
        return nil
    }
    
    private func validateConfirmation(_ confirmation: String) -> String? {
        if confirmation != password && !confirmation.isEmpty {
            return "Passwords do not match"
        }
        else {
            return nil
        }
    }
    
}

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}

#Preview {
    RegisterView()
}
