//
//  PasswordChangeView.swift
//  FF
//
//

import SwiftUI

struct PasswordChangeView: View {
    @State private var currentPw: String = ""
    @State private var newPw: String = ""
    @State private var confirmPw: String = ""
    //** Test with Preview
//    @State private var errorMsg: String = "Wrong"
    @State private var errorMsg: String? = ""
    @State private var isLoading: Bool = false
    
    //*** Different focus variables tracker
    @State private var toggleFocus1: Bool = false
    @State private var toggleFocus2: Bool = false
    @State private var toggleFocus3: Bool = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            //** Current password field
            VStack(alignment: .leading, spacing: 5) {
                Text("Enter your current password:")
                    .font(.system(size: 20, weight: .regular))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
                
                ZStack {
                    if !toggleFocus1 && currentPw.isEmpty {
                        Text("Current Password")
                            .padding(.trailing, 200)
                    }
                    
                    SecureField("", text: $currentPw)
                        .padding(.leading, 15)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
                        .onTapGesture {
                            toggleFocus1 = true
                            toggleFocus2 = false
                            toggleFocus3 = false
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
                
                ZStack {
                    if !toggleFocus2 && newPw.isEmpty {
                        Text("New Password")
                            .padding(.trailing, 225)
                    }
                    
                    SecureField("", text: $newPw)
                        .padding(.leading, 15)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
                        .onTapGesture {
                            toggleFocus1 = false
                            toggleFocus2 = true
                            toggleFocus3 = false
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
                
                ZStack {
                    if !toggleFocus3 && confirmPw.isEmpty {
                        Text("Verify Password")
                            .padding(.trailing, 218)
                    }
                    
                    SecureField("", text: $confirmPw)
                        .padding(.leading, 15)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
                        .onTapGesture {
                            toggleFocus1 = false
                            toggleFocus2 = false
                            toggleFocus3 = true
                        }
                }
            }
            .padding(.horizontal)
            
//            *** Test with live preview
//            Text(errorMsg)
//                .foregroundStyle(Color.red.opacity(0.80))
//                .padding()
            
            if let displayErrorMsg = errorMsg {
                Text(displayErrorMsg)
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
        
    } // end of body
} // end of struct

extension PasswordChangeView: StatusFormProtocol {
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
