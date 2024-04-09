//
//  User.swift
//  FF
//
//

import Foundation

// User Data Model [may need to switch for data model file for viewing visually]
struct User: Identifiable, Codable {            // codable turns JSON => data model object
    let id: String
    let username: String
    let firstName: String
    let lastName: String
    let email: String
    let imageArray: [String]
}

// test | admin account
extension User {
    static var ADMIN = User(id: NSUUID().uuidString, username: "admin", firstName: "Admin", lastName: "Admin", email: "admin@ff.com", imageArray: [])
}
