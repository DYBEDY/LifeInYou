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
    
    
    private let database = Firestore.firestore()
    private init() {}
    
    
    
    func validateNewUser(with email: String, completion: @escaping (Bool) -> Void) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
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
//    func delete(current task: TaskList, by user: User) {
//        database.database.reference(withPath: "users").child(String(user.uid)).child("tasks").child(task.name).removeValue()
//    }
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
}

