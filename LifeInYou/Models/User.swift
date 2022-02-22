//
//  User.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import Foundation
import Firebase



class User {
    let uid: String
    let email: String
    let userName: String
    let dateOfBirth: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email ?? ""
        self.userName = ""
        self.dateOfBirth = ""
    }
    
    init(email: String, uid: String, userName: String, dateOfBirth: String ) {
        self.email = email
        self.uid = uid
        self.userName = userName
        self.dateOfBirth = dateOfBirth
    }
    
   
}
