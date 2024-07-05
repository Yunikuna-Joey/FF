//
//  ReportProblemView.swift
//  FF
//
//

import SwiftUI
import MessageUI

struct ReportProblemView: View {
    @Binding var pageFlag: Bool
    @State private var subjectText: String = ""
    @State private var bodyText: String = ""
    
    @State private var showMailView: Bool = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    
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
                if MFMailComposeViewController.canSendMail() {
                    showMailView = true
                }
                else {
                    print("Cannot send mail")
                }
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
        .sheet(isPresented: $showMailView) {
            MailView(isShowing: $showMailView, result: $result, subject: subjectText, body: bodyText)
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

//** This will use the native iOS mail app to send out emails [configure on a per device basis]
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    var subject: String
    var body: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                isShowing = false
            }
            if let error = error {
                self.result = .failure(error)
            }
            else {
                self.result = .success(result)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, result: $result)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.setToRecipients([""]) // Use a valid email address here
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}



//#Preview {
//    ReportProblemView()
//}
