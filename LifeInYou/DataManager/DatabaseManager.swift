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
import FirebaseStorage

class DatabaseManager {
    static let shared = DatabaseManager()
    
    
    private let db = Firestore.firestore()
   

    private init() {}
    
    
    
    func validateNewUser(with email: String, completion: @escaping (Bool) -> Void) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
    }
    
    
    //MARK: - TaskList Methods
    
    
    
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
    

    func delete(current task: String, by user: User) {
        let oldTask = TaskList(name: task)
        self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(oldTask.name)").delete()
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
    
   
//    MARK: - New Task Methods
    
    func insertSecondTask(by user: User, fromTask: String, task: String, completionDate: String) {
            let fromTask = TaskList(name: fromTask)
            let newTask = Task(name: task, completionDate: completionDate)
//            newTask.imageURL = url
            DispatchQueue.main.async {
                self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(newTask.name)").setData([
                    "task" : newTask.name,
                    "completionDate" : newTask.completionDate,
                    "date" : newTask.date,
                    "isComplete" : newTask.isComplete,
                    "imageURL" : newTask.imageURL
                    
                ])
            }
        }
        
    
    
    func insertPhoto(by user: User, fromTask: String, task: String, completionDate: String, url: String) {
            let fromTask = TaskList(name: fromTask)
            let newTask = Task(name: task, completionDate: completionDate)
            newTask.imageURL = url
            DispatchQueue.main.async {
                self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(newTask.name)").setData([
                    "task" : newTask.name,
                    "completionDate" : newTask.completionDate,
                    "date" : newTask.date,
                    "isComplete" : newTask.isComplete,
                    "imageURL" : newTask.imageURL
                    
                ])
            }
        }
        
    func deleteTaskFromCollection(current task: String, from document: String, by user: User) {
        let currentTask = TaskList(name: document)
        let task = Task(name: task)
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(currentTask.name)").collection("tasks").document("\(task.name)").delete()
        }
    }

        
        
    func editCollectionTask(by user: User,in task: String, oldTask: String, newTask: String, completionDate: String) {
        let oldTask = Task(name: oldTask)
        let newTask = Task(name: newTask)
        let completionDate = Task(completionDate: completionDate)
        let task = TaskList(name: task)

        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(oldTask.name)").delete()
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(newTask.name)").setData([
                "task" : newTask.name,
                "completionDate" : completionDate.completionDate,
                "date" : newTask.date,
                "isComplete" : newTask.isComplete,
                "imageURL" : newTask.imageURL
            ])
        }
    }
        
    
//MARK: - Photo Methods
    func upload(user: String, fromTask: String, task: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fromTask = TaskList(name: fromTask)
        let newTask = Task(name: task)
        
        let ref = Storage.storage().reference().child("users").child(user).child("taskList").child(fromTask.name).child(newTask.name)

        guard let imageData = photo.jpegData(compressionQuality: 0.5) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
        ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }

    
    
    
    

//MARK: - Task Methods
    
    

    func insertSecondTaskk(by user: User, fromTask: String, task: String, note: String) {
        let fromTask = TaskList(name: fromTask)
        let newTask = Task(name: task, completionDate: note)
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(newTask.name)").setData([
                "task" : newTask.name,
                "note" : newTask.completionDate,
                "date" : newTask.date,
                "isComplete" : newTask.isComplete

            ])
        }
    }

    func deleteSecondTask(current task: Task, from document: String, by user: User) {
        let currentTask = TaskList(name: document)
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(currentTask.name)").collection("tasks").document("\(task.name)").delete()
        }
    }


    func editSecondTask(by user: User,in task: String, oldTask: String, newTask: String, newNote: String) {
        let oldTask = Task(name: oldTask)
        let newTask = Task(name: newTask)
        let newNote = Task(completionDate: newNote)
        let task = TaskList(name: task)

        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(oldTask.name)").delete()
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(newTask.name)").setData([
                "task" : newTask.name,
                "note" : newNote.completionDate,
                "date" : newTask.date,
                "isComplete" : newTask.isComplete
            ])
        }
    }


    func isDoneTask(by user: User, fromTask: TaskList, task: Task) {
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(task.name)").setData([
                "task" : task.name,
                "note" : task.completionDate,
                "date" : task.date,
                "isComplete" : task.isComplete
            ])

        }
    }

}


    



