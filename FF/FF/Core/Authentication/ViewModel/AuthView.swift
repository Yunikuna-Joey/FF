//
//  AuthView.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// decorator for the main 'pipeline'
@MainActor
class AuthView: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentSession: User?
    
    // check for a current user [behavior: keeps user signed in when exiting the app]
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        print("sign-in function")
    }
    
    // the user is being created.. [test with firebase and check usermodel]
    func createUser(withEmail email: String, password: String, firstName: String, lastName: String) async throws {
        print("Create-user function")
        do {
            // Firebase registration
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Data Model registration
            let user = User(id: result.user.uid, firstName: firstName, lastName: lastName, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            
            // upload data to firestore on this line
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
        }
        catch {
            print("[DEBUG]: Failed to create user with error \(error.localizedDescription)")
        }
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
