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
    
    // blank value
//    @State private var imageArray = [""]
    @State private var imageHashMap: [Int: [String]] = [:]
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case field1, field2, field3, field4, field5, field6
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .focused($focusedField, equals: .field1)
                    .onTapGesture {
                        focusedField = .field1
                    }
                
                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                    .focused($focusedField, equals: .field2)
                    .onTapGesture {
                        focusedField = .field2
                    }
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.33))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                    .focused($focusedField, equals: .field3)
                    .onTapGesture {
                        focusedField = .field3
                    }
                
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
                    .focused($focusedField, equals: .field4)
                    .onTapGesture {
                        focusedField = .field4
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
                    .focused($focusedField, equals: .field5)
                    .onTapGesture {
                        focusedField = .field5
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
                    .focused($focusedField, equals: .field6)
                    .onTapGesture {
                        focusedField = .field6
                    }
                
                // Error field for the confirmation field
                if let confirmationError = confirmationError {
                    Text(confirmationError)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                
                Button(action: {
                    Task {
                        // success of registration
                        do {
                            try await viewModel.createUser(withEmail: email, password: password, firstName: firstName, lastName: lastName, username: username, databaseUsername: username.lowercased(), imageHashMap: imageHashMap)
                            success = true
                        }
                        // catch error
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
                        .disabled(validForm)
                        .opacity(validForm ? 1.0 : 0.5)
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
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
    
    // validate confirmation password
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
    // validate email 
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}

extension RegisterView: AuthenticationFormProtocol {
    // add in a username check here as well
    var validForm: Bool {
        let symbols = "!@#$%^&*()_+\\-=[]{};':\"|,.<>/?"
        
        
        // these conditions must be true in order for the form to be valid
        return !email.isEmpty &&
            email.contains("@") &&
            !password.isEmpty && 
            password.count >= 8 &&
            !firstName.isEmpty &&
            !lastName.isEmpty &&
            confirmation == password &&
            password.contains(where: {$0.isNumber}) &&
            password.contains(where: {$0.isUppercase}) &&
            password.contains(where: {symbols.contains($0) })
    }
}

#Preview {
    RegisterView()
}
