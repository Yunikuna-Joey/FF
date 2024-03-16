//
//  User.swift
//  FF
//
//

import Foundation

// User Data Model
struct User: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
}

// test | admin account
extension User {
    static var ADMIN = User(id: NSUUID().uuidString, firstName: "Admin", lastName: "Admin", email: "admin@ff.com")
}
