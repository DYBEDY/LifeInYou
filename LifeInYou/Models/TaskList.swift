//
//  TaskList.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//


import Foundation
//import Firebase
//import FirebaseFirestore

class TaskList: Equatable {
    static func == (lhs: TaskList, rhs: TaskList) -> Bool {
        return lhs.name == rhs.name && lhs.userId == rhs.userId
    }
    
    var name: String
    var userId: String
    var date = Date()
    var tasks = [Task]()
    
    
    init(name: String, userId: String, date: Date) {
        self.name = name
        self.userId = userId
        self.date = date

    }
    
    
    init(name: String) {
        self.name = name
        self.userId = ""

    }
    init(name: String, tasks: [Task]) {
        self.name = name
        self.tasks = tasks
        self.userId = ""
}
    
}

class Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.name == rhs.name && lhs.note == rhs.note && lhs.isComplete == rhs.isComplete
    }
    
    var name: String
    var note: String
    var date = Date()
    var isComplete: Bool
 
    init(name: String = "", note: String = "", isComplete: Bool = false) {
        self.name = name
        self.note = note
        self.isComplete = isComplete
    }
    
}


