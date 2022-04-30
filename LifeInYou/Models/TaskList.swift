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
    var date: Date
    var tasks = [Task]()
    
    
    init(name: String, userId: String, date: Date) {
        self.name = name
        self.userId = userId
        self.date = date

    }
    
    init(name: String, userId: String) {
        self.name = name
        self.userId = userId
        self.date = Date()
    }
    
    init(name: String) {
        self.name = name
        self.userId = ""
        self.date = Date()
    }
    
    
    
    init(name: String, tasks: [Task]) {
        self.name = name
        self.tasks = tasks
        self.userId = ""
        self.date = Date()
}
    init(name: String, date: Date) {
        self.name = name
        self.date = date
        self.userId = ""
    }
    
}

class Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.name == rhs.name && lhs.completionDate == rhs.completionDate && lhs.isComplete == rhs.isComplete
    }
    
    var name: String
    var completionDate: String
    var date = Date()
    var isComplete: Bool
    var imageURL: String
    
    init(name: String = "", completionDate: String = "", isComplete: Bool = false, imageUrl: String = "") {
        self.name = name
        self.completionDate = completionDate
        self.isComplete = isComplete
        self.imageURL = imageUrl
        
    }
    init(name: String = "", completionDate: String = "", date: Date, isComplete: Bool = false, imageURL: String) {
        self.name = name
        self.completionDate = completionDate
        self.date = date
        self.isComplete = isComplete
        self.imageURL = imageURL
    }
    
    init(name: String = "") {
        self.name = name
        self.completionDate = ""
        self.date = Date()
        self.isComplete = false
        self.imageURL = ""
    }
    
}


