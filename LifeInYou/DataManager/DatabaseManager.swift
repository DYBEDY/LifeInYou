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
    
    func inserNewTaskwithOldDate(by user: User, task: String, oldTask: String) {
        let newTask = TaskList(name: task)
        let oldTask = TaskList(name: oldTask)
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(oldTask.name)").getDocument { doc, error in
                if error == nil {
                    let data = doc?.data()
                    self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(newTask.name)").setData(data ?? ["": ""])
                    self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(newTask.name)").updateData([
                        "task": newTask.name
                    ])
                    self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(oldTask.name)").delete()
                }
            }
              
        }
        
    }
    

    func delete(current task: String, by user: User) {
        let oldTask = TaskList(name: task)
        self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(oldTask.name)").delete()
    }
    
    

    
   
//    MARK: - New Task Methods
    
    func insertSecondTask(by user: User, fromTask: String, task: String, completionDate: String) {
            let fromTask = TaskList(name: fromTask)
            let newTask = Task(name: task, completionDate: completionDate)
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
        
    func isDoneSecondTask(by user: User, fromTask: TaskList, task: Task) {
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(task.name)").setData([
                "task" : task.name,
                "completionDate" : task.completionDate,
                "date" : task.date,
                "isComplete" : task.isComplete,
                "imageURL" : task.imageURL
                
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

        
    func editCollectionTask(by user: User,in task: String, oldTask: String, newTask: String?, completionDate: String, isComplete: Bool) {
        let oldTask = Task(name: oldTask)
        let newTask = Task(name: newTask ?? "")
    
        
        let task = TaskList(name: task)

        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(oldTask.name)").getDocument { doc, error in
                if error == nil {
                    self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(oldTask.name)").delete()
                    
                    let data = doc?.data()
                    self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(newTask.name)").setData(data ?? ["" : ""])
                    self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").document("\(newTask.name)").updateData([
                        "task" : newTask.name,
                        "isComplete" : isComplete,
                        "completionDate" : completionDate,
                        "imageURL" : newTask.imageURL
                    ])
                    
                    
                    
                }
            }
        }
    }
    

    
//MARK: - Photo Methods
    func upload(user: String, fromTask: String, task: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fromTask = TaskList(name: fromTask)
        let newTask = Task(name: task)
        
        let ref = Storage.storage().reference().child("users").child(user).child("taskList").child(fromTask.name).child(newTask.name)

        guard let imageData = photo.jpegData(compressionQuality: 0.4) else { return }
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
    
    
    func uploadPhoto(user: String, fromTask: String, task: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let fromTask = TaskList(name: fromTask)
        let newTask = Task(name: task)
        
        let ref = Storage.storage().reference().child("users").child(user).child("taskList").child(fromTask.name).child(newTask.name)

        guard let imageData = UIImage().jpegData(compressionQuality: 0.4) else { return }
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
    
    
   
    

    
    func downloadImage(user: String, fromTask: TaskList, task: Task, completion: @escaping (Result<UIImage, Error>) -> Void) {

        let ref = Storage.storage().reference().child("users").child(user).child("taskList").child(fromTask.name).child(task.name).storage.reference(forURL: task.imageURL)

        let megaByte = Int64(1 * 1024 * 1024)
        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(.failure(error!))
                return
            }
            guard let image = UIImage(data: imageData) else {
                completion(.failure(error!))
                return
            }
            completion(.success(image))

        }
    }
    
 
    
    
    
    func deletePhoto(user: String, taskList: String, currentTask: String) {
        let taskList = TaskList(name: taskList)
        let currentTask = Task(name: currentTask)
        let ref = Storage.storage().reference().child("users").child(user).child("taskList").child(taskList.name).child(currentTask.name)
        DispatchQueue.main.async {
            ref.delete()
            
        }
        
        
        
    }
    
    func insertPhoto(by user: User, fromTask: String, task: String, completionDate: String, isComplete: Bool, url: String) {
            let fromTask = TaskList(name: fromTask)
            let newTask = Task(name: task, completionDate: completionDate)
            newTask.imageURL = url
            DispatchQueue.main.async {
                self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(newTask.name)").setData([
                    "task" : newTask.name,
                    "completionDate" : newTask.completionDate,
                    "date" : newTask.date,
                    "isComplete" : isComplete,
                    "imageURL" : newTask.imageURL
                    
                ])
            }
        }
    

    
    
    
    func editPhoto(user: String, taskList: String, currentTask: String) {
        let taskList = TaskList(name: taskList)
        let currentTask = Task(name: currentTask)
        let ref = Storage.storage().reference().child("users").child(user).child("taskList").child(taskList.name).child(currentTask.name)
        DispatchQueue.main.async {
            ref.delete()
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


    func isDoneTaskk(by user: User, fromTask: TaskList, task: Task) {
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(fromTask.name)").collection("tasks").document("\(task.name)").updateData([
                "task" : task.name,
                "completionDate" : task.completionDate,
                "date" : task.date,
                "isComplete" : task.isComplete,
                "imageURL" : task.imageURL
                
            ])
        }
    }

}


    



