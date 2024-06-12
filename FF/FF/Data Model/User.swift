//
//  User.swift
//  FF
//
//

import Foundation

// User Data Model [may need to switch for data model file for viewing visually]
struct User: Identifiable, Codable, Hashable {            // codable turns JSON => data model object
    
    let id: String
    let username: String
    let databaseUsername: String
    let firstName: String
    let lastName: String
    let email: String
//    let imageArray: [String]
    // make a hashmap so that [Position # : [array of picture urls?]
    var imageHashMap: [Int : [String]]
    var profilePicture: String
    let coverPicture: String
}

// test | admin account
//extension User {
//    static var ADMIN = User(id: NSUUID().uuidString, username: "admin", databaseUsername: "admin", firstName: "Admin", lastName: "Admin", email: "admin@ff.com", imageArray: [], profilePicture: "person.circle", coverPicture: "person.circle.fill")
//}
