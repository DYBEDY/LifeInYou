//
//  TaskList.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//


import Foundation
import Firebase
import FirebaseFirestore

class TaskList: Equatable {
    static func == (lhs: TaskList, rhs: TaskList) -> Bool {
        return lhs.name == rhs.name && lhs.userId == rhs.userId
    }
    
    var name: String
    var userId: String
   
    
    
    init(name: String, userId: String) {
        self.name = name
        self.userId = userId
//        self.ref = nil
    }
    
    
//    init(snapshot: DataSnapshot) {
//        let snapshotValue = snapshot.value as! [String: Any]
//        name = snapshotValue["name"] as! String
//        userId = snapshotValue["userId"] as! String
//        ref = snapshot.ref
//    }
    
    init(name: String) {
        self.name = name
        self.userId = ""
//        self.ref = nil
        
    }
}

class Task {
    var name = ""
    var note = ""
    var date = Date()
    var isComplete = false
}


