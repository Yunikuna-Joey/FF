//
//  SettingView.swift
//  FF
//
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var viewModel: AuthView
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let currentUserObject = viewModel.currentSession {
                    if currentUserObject.profilePicture.isEmpty {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .padding(.top, 40)
                    }
                    else {
                        AsyncImage(url: URL(string: currentUserObject.profilePicture)) { phase in
                            switch phase {
                                // Different cases the request might encounter: loading | success | None
                            case .empty:
                                ProgressView()
                                    .frame(width: 200, height: 150)
                                    .padding(.top, 40)
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .frame(width: 200, height: 150)
                                    .clipShape(Circle())
                                    .padding(.top, 40)
                                
                                
                            case .failure:
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 150)
                                    .clipShape(Circle())
                                    .padding(.top, 40)
                                
                            @unknown default:
                                EmptyView()
                            } // end of switch
                            
                        } // end of async image
                        
                    }
                    
                    // Test this portion in prod
                    Text(viewModel.currentSession?.username ?? "User")
                        .font(.headline)
                }
                
//                Text("Username")
//                    .font(.title)
                
                List {
                    Section {
                        HStack {
                            Image(systemName: "envelope")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 10)
                                .foregroundStyle(Color.blue.opacity(0.80))
                            
                            Text("Email Content")
                                .foregroundStyle(Color.primary)
                        }
                        
                        Button(action: {
                            print("Act as the change password button")
                        }) {
                            HStack {
                                Image(systemName: "lock.square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 10)
                                    .foregroundStyle(Color.blue.opacity(0.80))
                                
                                Text("Change Password")
                                    .foregroundStyle(Color.primary)
                            }
                        }
                        
                        Button(action: {
                            print("Act as the report a problem button")
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.bubble")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 10)
                                    .foregroundStyle(Color.blue.opacity(0.80))
                                
                                Text("Report a problem")
                                    .foregroundStyle(Color.primary)
                            }
                        }
                        
                        Button(action: {
                            print("Act as the privacy policy button")
                        }) {
                            HStack {
                                Image(systemName: "hand.raised.app.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 10)
                                    .foregroundStyle(Color.blue.opacity(0.80))
                                
                                Text("Privacy Policy")
                                    .foregroundStyle(Color.primary)
                            }
                        }
                        
                    } // end of section 1
                    
                    Section {
                        Button(action: {
                            viewModel.signOut()
                            print("Settings page sign out button")
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 10)
                                    .foregroundStyle(Color.red)
                                Text("Sign out!")
                                    .foregroundStyle(Color.primary)
                            }
                        }
                    } // end of section 2
                    
                } // end of list
                
                
            } // end of VStack
            .background(Color(.systemGroupedBackground))
            
        } // end of navigationStack
    }
}



#Preview {
    SettingView()
}
