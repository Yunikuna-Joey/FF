//
//  AuthView.swift
//  FF
//
//

import Foundation
import FirebaseAuth
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
    
    // *** This will act as a cache [temporarily...]
    @Published var userCache: [String: User] = [:]
    
    // database variable
    private let dbUsers = Firestore.firestore().collection("users")
    private let db = Firestore.firestore()
    
    var messageManager: MessageManager
    
    // check for a current user [behavior: keeps user signed in when exiting the app]
    init() {
        // Attempting to maintain current user from previous session
        self.userSession = Auth.auth().currentUser
        
        // injecting and ensuring that message Manager is in here
        self.messageManager = MessageManager()
        
        // attempt to grab user data when the app is open
        Task {
            await fetchUser()
        }
    }
    
    // Fetches the latest UserObject information
    func getUserFromCache(userId: String) -> User? {
        return userCache[userId]
    }
    
    // Updates the latest UserObject information
    func updateUserCache(user: User) {
        userCache[user.id] = user
    }
    
    // Return a User Object given an id
    func convertUserIdToObject(_ userId: String) async throws -> User? {
        let userRef = dbUsers.document(userId)
        
        do {
            let document = try await userRef.getDocument()
            if let user = try document.data(as: User?.self) {
                return user
            }
            else {
                return nil
            }
        }
        
        catch {
            print("[convertUserIdToObject]: Error fetching a user: \(error.localizedDescription)")
            throw error
        }
    }
    
    // sign-in function
    func signIn(withEmail email: String, password: String) async throws -> Bool {
        print("sign-in function")
        do {
            // responds with a firebase user object
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            // set the app-user to be the firebase object
            self.userSession = result.user
            
            // grab user information
            await fetchUser()
            
            // false meaning there was no error
            return false
        }
        catch {
            print("[DEBUG]: Failed to log in with error \(error.localizedDescription)")
            
            // true meaning there was an error 
            return true
        }
    }
    
    // the user is being created..
    func createUser(withEmail email: String, password: String, firstName: String, lastName: String, username: String, databaseUsername: String, imageHashMap: [Int : [String]]) async throws {
        print("Create-user function")
        do {
            // Firebase registration
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Data Model registration
            let user = User(id: result.user.uid, username: username, databaseUsername: username.lowercased(), firstName: firstName, lastName: lastName, email: email, imageHashMap: imageHashMap, profilePicture: "", coverPicture: "")
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
            self.messageManager.inboxList = []
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
//        print("This is the current user id \(currentUserId)")
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
        
        if let userSessionStatement = self.userSession {
            print("[DEBUG]: User session is \(self.userSession ?? userSessionStatement)")
            print("[DEBUG]: Current User is \(self.currentSession ?? EmptyVariable.EmptyUser)")
        }
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
    
    // grab a user's images from their profile
    func fetchUserImages(userId: String) async -> [String] {
        var imageList: [String] = []
        
        do {
            // make a query to the user
            let querySnapshot = try await db.collection("users")
                .whereField("id", isEqualTo: userId)
                .getDocuments()
            
            // Check if any documents were returned
            guard !querySnapshot.isEmpty else {
                print("No documents were found for this user \(userId)")
                return imageList
            }
            
            // Iterate through the documents [there should always be one]
            for document in querySnapshot.documents {
                // find the imageArray field
                if let images = document.data()["imageArray"] as? [String] {
                    imageList = images
                }
            }
        }
        
        catch {
            print("[DEBUG]: There was an error fetching user images \(error.localizedDescription)")
        }
        
        return imageList
    }
    
    // Updates the profile picture for a given userID [currentUser scenario]
    func updateProfilePicture(userId: String, profilePictureUrl: String) {
        guard !userId.isEmpty else {
            print("[Error]: userId is empty.")
            return
        }
        
        let query = Firestore.firestore().collection("users")
            .document(userId)
            
        
        query.updateData(["profilePicture": profilePictureUrl]) { error in
            if let error = error {
                print("[DEBUG]: Error updating profile picture \(error.localizedDescription)")
            }
            
            else {
                print("Updating profile picture was successful")
            }
        }
        
        print("end of function")
    }
    
    func updateCoverPicture(userId: String, coverPictureUrl: String) {
        guard !userId.isEmpty else {
            print("Error: userId is empty")
            return
        }
        
        let query = Firestore.firestore().collection("users")
            .document(userId)
        
        query.updateData(["coverPicture": coverPictureUrl]) { error in
            if let error = error {
                print("[DEBUG]: Error updating the cover picture \(error.localizedDescription)")
            }
            
            else {
                print("Updating cover picture was successful")
            }
        }
    }
    
    // the parameters for this function are the currentUserId and an array of picture Urls assuming there are multiple pictures within a status post
    func updateUserImageHashMap(userId: String, newImageUrls: [String]) async throws {
        let query = dbUsers.document(userId)
        
        do {
            // Grab the current user data/document
            let currSnapshot = try await query.getDocument()
            guard var user = try? currSnapshot.data(as: User.self) else {
                throw NSError(domain: "User data not found", code: 404, userInfo: nil)
            }
            
            // Access the imageHashMap safely
            var imageHashMap = user.imageHashMap
            
            // Find the next available key
            let nextKey = (imageHashMap.keys.max() ?? -1) + 1
            
            // Add the new image URLs to the hashmap
            imageHashMap[nextKey] = newImageUrls
            
            // Update the user with the modified imageHashMap
            user.imageHashMap = imageHashMap
            try query.setData(from: user, merge: true)
            
            print("[updateUserImageHashMap]: Updated user imageHashMap successfully")
        } catch {
            print("There was an error updating the user imageHashMap: \(error.localizedDescription)")
            throw error
        }
    }
    
    //*** attaches an event listener to the user document to determine if any changes were made
    func listenForUpdates(userObject: User) {
        dbUsers.document(userObject.id).addSnapshotListener { documentSnapshot, error in
            // Ensure there is a valid document
            guard let document = documentSnapshot else {
                print("[listenForUpdate]: Error fetching document \(error?.localizedDescription ?? "[listenForUpdate]: Unknown Error")")
                return
            }
            
            do {
                // Invokes re-rendering of the view because session property is modified
                self.currentSession = try document.data(as: User.self)
            }
            
            catch {
                print("[listenForUpdate]: Error decoding user information \(error.localizedDescription)")
            }
        }
        
        print("[listenForUpdates]: Triggered user listener function")
    }
    
    //*** Test out authenticating current user object for password changing storyboard
    func authenticateUser(currPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let userObject = Auth.auth().currentUser else {
            completion(false, "No user is currently logged in")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: userObject.email!, password: currPassword)
        
        userObject.reauthenticate(with: credential) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
            }
            else {
                completion(true, nil)
            }
        }
    }
    
    func changeUserPassword(newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            }
            else {
                completion(true, nil)
            }
        }
    }
}

//#Preview {
//    AuthView()
//}
