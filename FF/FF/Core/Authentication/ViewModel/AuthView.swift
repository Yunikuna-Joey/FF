//
//  AuthView.swift
//  FF
//
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// determine if the form is valid [universal]
protocol AuthenticationFormProtocol {
    var validForm: Bool { get }
}

// decorator for the main 'pipeline'
@MainActor
class AuthView: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentSession: User?
    @Published var currentUsername: String?
    
    // database variable
    private let db = Firestore.firestore()
    
    // check for a current user [behavior: keeps user signed in when exiting the app]
    init() {
        // Attempting to maintain current user from previous session
        self.userSession = Auth.auth().currentUser
        
        // attempt to grab user data when the app is open
        Task {
            await fetchUser()
        }
    }
    
    // sign-in function
    func signIn(withEmail email: String, password: String) async throws {
        do {
            // responds with a firebase user object
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            // set the app-user to be the firebase object
            self.userSession = result.user
            
            // grab user information
            await fetchUser()
        }
        catch {
            print("[DEBUG]: Failed to log in with error \(error.localizedDescription)")
        }
        print("sign-in function")
    }
    
    // the user is being created.. [test with firebase and check usermodel]
    func createUser(withEmail email: String, password: String, firstName: String, lastName: String, username: String, imageArray: [String]) async throws {
        print("Create-user function")
        do {
            // Firebase registration
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Data Model registration
            let user = User(id: result.user.uid, username: username, firstName: firstName, lastName: lastName, email: email, imageArray: imageArray)
            let encodedUser = try Firestore.Encoder().encode(user)
            
            // upload data to firestore on this line
            try await db.collection("users").document(user.id).setData(encodedUser)
            
            await fetchUser()
        }
        catch {
            print("[DEBUG]: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    // sign out function
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
        
    }
    
    func queryCurrentUserId() -> String? {
        let currentUserId = Auth.auth().currentUser?.uid
        print("This is the current user id \(currentUserId)")
        return currentUserId
    }

    
    // fill in later.. [COME-BACK]
    func deleteAccount() {
        print("delete account")
    }
    
    // grab user information
    func fetchUser() async  {
        // unique id
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // instance of user object
        guard let snapshot = try? await db.collection("users").document(uid).getDocument() else { return }
        // set the current session to be the signed-in user
        self.currentSession = try? snapshot.data(as: User.self)
        
        print("[DEBUG]: User session is \(self.userSession)")
        print("[DEBUG]: Current User is \(self.currentSession)")
    }
    
    // fetch ALL USER data [Data Visualization]
    func fetchAllUsers() async {
        Task {
            do {
                print("Fetching all users...")
                let querySnapshot = try await Firestore.firestore().collection("users").getDocuments()
                
                // Print table header
                print("| ID | Username | First Name | Last Name | Email |")
                print("---------------------------------------------------")
                
                for document in querySnapshot.documents {
                    if let userData = try? document.data(as: User.self) {
                        // Format user data into a table row
                        let tableRow = String(format: "| %@ | %@ | %@ | %@ | %@ |", userData.id, userData.username, userData.firstName, userData.lastName, userData.email)
                        print(tableRow)
                    }
                }
            }
            catch {
                print("Error fetching users: \(error.localizedDescription)")
            }
        }
    }
}

//#Preview {
//    AuthView()
//}
