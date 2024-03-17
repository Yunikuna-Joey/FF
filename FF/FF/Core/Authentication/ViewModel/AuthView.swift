//
//  AuthView.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var validForm: Bool { get }
}

// decorator for the main 'pipeline'
@MainActor
class AuthView: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentSession: User?
    
    // check for a current user [behavior: keeps user signed in when exiting the app]
    init() {
        // Attempting to maintain current user from previous session
        self.userSession = Auth.auth().currentUser
        
        // attempt to grab user data when the app is open
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            
             await fetchUser()
        }
        catch {
            print("[DEBUG]: Failed to log in with error \(error.localizedDescription)")
        }
        print("sign-in function")
    }
    
    // the user is being created.. [test with firebase and check usermodel]
    func createUser(withEmail email: String, password: String, firstName: String, lastName: String, username: String) async throws {
        print("Create-user function")
        do {
            // Firebase registration
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Data Model registration
            let user = User(id: result.user.uid, username: username, firstName: firstName, lastName: lastName, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            
            // upload data to firestore on this line
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            
            await fetchUser()
        }
        catch {
            print("[DEBUG]: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            // sign out user on the backend
            try Auth.auth().signOut()
            // clears user session in presentation view
            self.userSession = nil
            // clears current user in presentation view [removes old data / previous data from previous current user]
            self.currentSession = nil
        }
        catch {
            print("[DEBUG]: Failed to sign out with error \(error.localizedDescription)")
        }
        
        print("sign-out function")
    }
    
    func deleteAccount() {
        print("delete account")
    }
    
    func fetchUser() async  {
        print("Fetch-user function")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentSession = try? snapshot.data(as: User.self)
        
        print("[DEBUG]: User session is \(self.userSession)")
        print("[DEBUG]: Current User is \(self.currentSession)")
    }
}

//#Preview {
//    AuthView()
//}
