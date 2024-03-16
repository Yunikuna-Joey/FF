//
//  AuthView.swift
//  FF
//
//

import Foundation
import Firebase

class AuthView: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentSession: User?
    
    init() {
        
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        print("sign-in function")
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        print("Create-user function")
    }
    
    func signOut() {
        print("sign-out function")
    }
    
    func deleteAccount() {
        print("delete account")
    }
    
    func fetchUser() async  {
        print("Fetch-user function")
    }
}

//#Preview {
//    AuthView()
//}
