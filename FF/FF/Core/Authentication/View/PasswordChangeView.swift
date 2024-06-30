//
//  PasswordChangeView.swift
//  FF
//
//

import SwiftUI

struct PasswordChangeView: View {
    @EnvironmentObject var viewModel: AuthView
    
    @State private var currentPw: String = ""
    @State private var newPw: String = ""
    @State private var confirmPw: String = ""
    
    //** Test with Preview
//    @State private var errorMsg: String = "Wrong"
    @State private var currMsg: String? = ""
    @State private var passwordMsg: String? = ""
    @State private var confirmationMsg: String? = ""
    @State private var isLoading: Bool = false
    
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case currField, newField, confirmField
    }

    
    
    var body: some View {
        VStack(spacing: 20) {
            //** Current password field
            VStack(alignment: .leading, spacing: 5) {
                Text("Enter your current password:")
                    .font(.system(size: 20, weight: .regular))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
                
                ZStack(alignment: .leading) {
                    if currentPw.isEmpty && focusedField != .currField {
                        Text("Current Password")
                            .padding(.leading, 10)
                    }
                    
                    SecureField("", text: $currentPw)
                        .padding(.leading, 15)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
                        .focused($focusedField, equals: .currField)
                        .onTapGesture {
                            focusedField = .currField
                        }

                }
            }
            .padding(.horizontal)
            
            //** New password field
            VStack(alignment: .leading, spacing: 5) {
                Text("Enter your new password:")
                    .font(.system(size: 20, weight: .regular))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
                
                ZStack(alignment: .leading) {
                    if newPw.isEmpty && focusedField != .newField {
                        Text("New Password")
                            .padding(.leading, 10)
                    }
                    
                    SecureField("", text: $newPw)
                        .padding(.leading, 15)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
                        .onChange(of: newPw) { _, newChar in
                            passwordMsg = ConstantFunction.validatePassword(newChar)
                        }
                        .focused($focusedField, equals: .newField)
                        .onTapGesture {
                            focusedField = .newField
                        }
                }
            }
            .padding(.horizontal)
            
            //** Confirm password field
            VStack(alignment: .leading, spacing: 5) {
                Text("Confirm your password:")
                    .font(.system(size: 20, weight: .regular))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
                
                ZStack(alignment: .leading) {
                    if confirmPw.isEmpty && focusedField != .confirmField {
                        Text("Verify Password")
                            .padding(.leading, 10)
                    }
                    
                    SecureField("", text: $confirmPw)
                        .padding(.leading, 15)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
                        .onChange(of: confirmPw) { _, newChar in
                            confirmationMsg = validateConfirmation(newChar)
                        }
                        .focused($focusedField, equals: .confirmField)
                        .onTapGesture {
                            focusedField = .confirmField
                        }
                }
            }
            .padding(.horizontal)
            
//            *** Test with live preview
//            Text(errorMsg)
//                .foregroundStyle(Color.red.opacity(0.80))
//                .padding()
            
            //*** Error Area
            if let errorMsg = passwordMsg {
                Text(errorMsg)
                    .foregroundStyle(Color.red)
                    .padding()
            }
            
            if let errorMsg = confirmationMsg {
                Text(errorMsg)
                    .foregroundStyle(Color.red)
                    .padding()
            }
            
            if let errorMsg = currMsg {
                Text(errorMsg)
                    .foregroundStyle(Color.red)
                    .padding()
            }
            
            // ** button stack
            HStack(spacing: 75) {
                Button(action: {
                    print("This will act as the cancel button")
                }) {
                    Text("Cancel")
                        .frame(width: 100, height: 40)
                        .fontWeight(.bold)
                }
                .background(Color.gray.opacity(0.25))
                .cornerRadius(20)
                
                Button(action: {
                    print("This will act as the save/continue button")
                    
                }) {
                    Text("Save Changes")
                        .frame(width: 150, height: 40)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .background(Color.blue)
                .cornerRadius(20)
                .opacity(validForm ? 1.0 : 0.5)
                .disabled(!validForm)
            }
            
        } // end of VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
    } // end of body
    
    // ** Helper function
    private func validateConfirmation(_ confirmation: String) -> String? {
        if confirmation != newPw && !confirmation.isEmpty {
            return "Passwords do not match."
        }
        else {
            return nil
        }
    }
    
    private func invokePasswordChange() {
        viewModel.authenticateUser(currPassword: currentPw) { success, error in
            //* catch error
            if let error = error {
                self.currMsg = "Eneter the correct current password"
            }
            //* Proceed as normal
            else {
                viewModel.changeUserPassword(newPassword: newPw) { success, error in
                    if let error = error {
                        print("[InvokePasswordChange]: what")
                    }
                    else {
                        print("[InvokePasswordChange]: It worked?")
                    }
                }
            }
        }
    }
    
} // end of struct

extension PasswordChangeView: StatusFormProtocol {
    //** Fill in the requirements for a password here before executing back-end functionality
    var validForm: Bool {
        // Ensure that all text fields are NOT empty
        return !currentPw.isEmpty &&
            !newPw.isEmpty &&
            !confirmPw.isEmpty
    }
}


#Preview {
    PasswordChangeView()
}
