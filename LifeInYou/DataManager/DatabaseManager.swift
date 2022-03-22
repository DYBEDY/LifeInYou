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
    
    
    
    
    func doneTask(_ task: TaskList, by user: User) {
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("tasks").document("\(task.name)").setData([
                "task" : task.name,
                "userid": user.uid
//                "isDone": task.isComplete.toggle()
            ], merge: true)
        }
    }
 
    
    func delete(current task: TaskList, by user: User) {
//        database.database.reference(withPath: "users").child(String(user.uid)).child("tasks").child(task.name).removeValue()
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").delete()
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
        
//
//
//        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
//            guard snapshot.value as? String != nil else {
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//
//
//
//    func insertUser(with user: User) {
//        database.database.reference(withPath: "users").child(String(user.uid)).child(user.safeEmail).setValue(["email": user.safeEmail])
//    }
//
//
//
//    func insertNewTask(by user: User,  task: TaskList) {
//        database.database.reference(withPath: "users").child(String(user.uid)).child("tasks").child(task.name).setValue([
//            "name": task.name,
//            "userId": task.userId])
//
//    }
      
//
//

//
//
    
//    func fetchData(to user: User, completion: @escaping([TaskList]) -> Void) {
//        database.database.reference(withPath: "users").child(String(user.uid)).child("tasks").observe(.value) { (snapshot) in
//            var tasks = Array<TaskList>()
//            for item in snapshot.children {
//                let task = TaskList(snapshot: item as! DataSnapshot)
//                tasks.append(task)
//                completion(tasks)
//            }
//        }
//    }
    
//
//
//
//    func edit(_ task: TaskList, newValue: String, by user: User) {
//        database.child("users/\(user.uid)/tasks\(task.name)").childByAutoId()
//    }
//
}


