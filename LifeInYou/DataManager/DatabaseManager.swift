//
//  DatabaseManager.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase

class DatabaseManager {
    static let shared = DatabaseManager()
    
    
    private let db = Firestore.firestore()
    private init() {}
    
  
    
    func validateNewUser(with email: String, completion: @escaping (Bool) -> Void) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
    }
    
    func inserNewTask(by user: User, task: String) {
        let newTask = TaskList(name: task)
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(newTask.name)").setData([
                "task" : newTask.name,
                "userid": user.uid,
                "date" : newTask.date
            ], merge: true)
        }
      
    }
    
    func insertSecondTask(by user: User, fromTask: String, task: String, note: String) {
        let fromTask = TaskList(name: fromTask)
        let newTask = Task(name: task, note: note)
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(newTask.name)").setData([
                "task" : newTask.name,
                "note" : newTask.note,
                "date" : newTask.date,
                "isComplete" : newTask.isComplete

            ])
        }
    }
    
    func isDoneTask(by user: User, fromTask: TaskList, task: Task) {
//        let task = Task(name: task)
//        task.isComplete.toggle()
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(task.name)").setData([
                "task" : task.name,
                "note" : task.note,
                "date" : task.date,
                "isComplete" : task.isComplete
            ])
            
            print(task.name, task.isComplete)
        }
    }

    

    func delete(current task: TaskList, by user: User) {
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").delete()
        }
    }
    
    
    func deleteSecondTask(current task: Task, from document: String, by user: User) {
        let currentTask = TaskList(name: document)
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(currentTask.name)").collection("tasks").document("\(task.name)").delete()
    }
    }
    

    
    func editTask(by user: User, oldTask: String, newTask: String) {
        let oldTask = TaskList(name: oldTask)
        let newTask = TaskList(name: newTask)
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(oldTask.name)").delete()
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(newTask.name)").setData([
                "task" : newTask.name,
                "userid": user.uid,
                "date" : newTask.date
            ], merge: true)
        }
    }
        
    
    func editSecondTask(by user: User,in task: String, oldTask: String, newTask: String, newNote: String) {
        let oldTask = Task(name: oldTask)
        let newTask = Task(name: newTask)
        let newNote = Task(note: newNote)
        let task = TaskList(name: task)
        
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(oldTask.name)").delete()
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(newTask.name)").setData([
                "task" : newTask.name,
                "note" : newNote.note,
                "date" : newTask.date,
                "isComplete" : newTask.isComplete
            ])
        }
    }
    
    
}


