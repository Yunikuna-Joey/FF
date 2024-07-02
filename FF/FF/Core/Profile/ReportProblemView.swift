//
//  ReportProblemView.swift
//  FF
//
//

import SwiftUI

struct ReportProblemView: View {
    @State private var subjectText: String = ""
    @State private var bodyText: String = ""
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            VStack (alignment: .leading, spacing: 5) {
                Text("Where is the issue located?")
                    .font(.system(size: 20, weight: .regular))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
                
                TextField("", text: $subjectText)
                    .padding(.leading, 15)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.80))
                    .cornerRadius(20)
                    .frame(maxWidth: 500)
            }
            .padding(.horizontal)
            
            VStack (alignment: .leading, spacing: 5) {
                Text("What is the issue?")
                    .font(.system(size: 20, weight: .regular))
                    .padding(.leading, 5)
                    .padding(.vertical, 5)
                
                TextEditor(text: $bodyText)
                    .padding(.leading, 15)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.80))
                    .cornerRadius(20)
                    .frame(maxWidth: 500)
                    .frame(height: 200)
            }
            .padding(.horizontal)
            
            
            Button(action: {
                print("Act as the submit feedback button")
            }) {
                Text("Submit Feedback")
                    .frame(width: 150, height: 40)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(5)
            }
            .background(Color.blue)
            .cornerRadius(20)
            .opacity(validForm ? 1.0 : 0.5)
            .disabled(!validForm)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
extension ReportProblemView: StatusFormProtocol {
    //** Fill in the requirements for a password here before executing back-end functionality
    var validForm: Bool {
        // Ensure that all text fields are NOT empty
        return !subjectText.isEmpty && !bodyText.isEmpty
    }
}

#Preview {
    ReportProblemView()
}
