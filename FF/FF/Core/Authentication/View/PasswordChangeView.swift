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
    
    
    var body: some View {
        VStack(spacing: 20) {
            //** Current password field
            VStack(alignment: .leading, spacing: 5) {
                Text("Enter your current password:")
                    .font(.system(size: 20, weight: .regular))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
                
                ZStack {
                    if currentPw.isEmpty {
                        Text("Current Password")
//                            .foregroundStyle(Color(red: 198/255, green: 198/255, blue: 200/255))
                            .padding(.trailing, 200)
                    }
                    
                    SecureField("", text: $currentPw)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
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
                    if newPw.isEmpty {
                        Text("New Password")
                            .padding(.trailing, 225)
                    }
                    
                    SecureField("", text: $newPw)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
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
                    if confirmPw.isEmpty {
                        Text("Verify Password")
                            .padding(.trailing, 218)
                    }
                    
                    SecureField("", text: $confirmPw)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.80))
                        .cornerRadius(20)
                        .frame(maxWidth: 500)
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
            
            HStack(spacing: 150) {
                Button(action: {
                    print("This will act as the cancel button")
                }) {
                    Text("Cancel")
                }
                
                Button(action: {
                    print("This will act as the save/continue button")
                }) {
                    Text("Save Changes")
                }
            }
            
        } // end of VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        
    } // end of body
} // end of struct



#Preview {
    PasswordChangeView()
}
