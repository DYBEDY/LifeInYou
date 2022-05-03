//
//  AllTasksViewController.swift
//  LifeInYou
//
//  Created by Roman on 19.04.2022.
//

import UIKit
import Firebase
import FirebaseFirestore
import SkeletonView



protocol AllTasksDelegate {
    func presentSecondView(taskList: TaskList)
    
    
}


protocol AllTask2Delegate {
    func updateValue()
}

protocol AllTasksShowMenuDelegate {
    func showContextMenu(for button: UIButton, at indexPath: IndexPath)
    
}







class AllTasksViewController: UIViewController, UICollectionViewDelegate, AllTasksDelegate, AllTask2Delegate {
  
   
    
  
    
    
   
    @IBOutlet var tableView: UITableView!
    

    var taskLists: [TaskList] = []
    
    let db = Firestore.firestore()
   
    
    
    
    var ediImage: UIImage!
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.backgroundColor = UIColor(hue: 146/360, saturation: 0, brightness: 0.79, alpha: 1)
        
        
        
        
    }
    
   
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    
    func updateTaskList(_ user: User, tableView: UITableView) {
     
        self.db.collection("users").document("\(user.uid)").collection("taskList").order(by: "date", descending: true).getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {

                        self.taskLists = snapshot.documents.map { d in

                            let task = TaskList(name: d["task"] as? String ?? "",
                                                userId: d["userId"] as? String ?? ""
                            )

                            let time = (d["date"] as? Timestamp)?.dateValue()
                            task.date = time ?? Date()

                            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").order(by: "date", descending: true).getDocuments { snapshot, error in
                                if error == nil {
                                    if let snapshot = snapshot {
                                        task.tasks = snapshot.documents.map { d in

                                            return Task(name: d["task"] as? String ?? "",
                                                        completionDate: d["completionDate"] as? String ?? "",
                                                        date: d["date"] as? Date ?? Date(),
                                                        isComplete: d["isComplete"] as? Bool ?? false,
                                                        imageURL: d["imageURL"] as? String ?? "https://"
                                            )

                                        }

//                                        tableView.reloadData()
                                       

                                        print("========\(self.taskLists.count)=======")

                                    }
//                                    tableView.reloadData()
                                }
                                tableView.reloadData()
                            }

                            return task

                        }

                    }
                }
            }
        }

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }

    
 

    
 
    
    
    func moveOnTaskViewController(tIndex: Int, cIndex: Int, task: Task, taskList: TaskList) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let newVC = storyBoard.instantiateViewController(withIdentifier: "TestViewController") as? TestViewController else { return }
       
        newVC.task = task
        newVC.taskList = taskList
        newVC.delegate = self
        newVC.url = ""
        newVC.isComplete = task.isComplete
        
        self.navigationController?.present(newVC, animated: true)
    }
    

    
    func presentSecondView(taskList: TaskList) {
        print(taskList.name)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let newVC = storyBoard.instantiateViewController(withIdentifier: "TestViewController") as? TestViewController else { return }
        
        
        newVC.taskList = taskList
        newVC.delegate = self
        newVC.isComplete = false
        self.navigationController?.present(newVC, animated: true)
    }
    
    
    func updateValue() {
        updateTaskList(user, tableView: tableView)
    }
    
  
    
}

//MARK: - TableView methods

extension AllTasksViewController: UITableViewDelegate, SkeletonTableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
         
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        "AllTasksTableViewCell"
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllTasksTableViewCell", for: indexPath) as! AllTasksTableViewCell
        let task = taskLists[indexPath.row]
      
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(hue: 146/360, saturation: 0, brightness: 0.79, alpha: 1)
        
        cell.indexPath = indexPath
        cell.taskList = task
        
        
        cell.showDelegate = self
        cell.configure(with: task)
        cell.delegate = self
       
        
        cell.didSelectClosure = { tabIndex, collIndex in
            let currentTask = task.tasks[collIndex ?? 0]
            self.moveOnTaskViewController(tIndex: tabIndex ?? 0, cIndex: collIndex ?? 0, task: currentTask, taskList: task)
        }
      
     
         
        return cell
    }
    
    
}


//MARK: - Action methods

extension AllTasksViewController {
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? "Изменить цель" : "Новая цель"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Задайте имя для новой цели")
        
        alert.action(with: taskList) { newValue in
            self.saveFunc(taskList: newValue)
        }
        present(alert, animated: true)
    }
    
    
    private func saveFunc(taskList: String) {
        let newTask = TaskList(name: taskList)
       
        self.taskLists.insert(newTask, at: 0)
        self.tableView.insertRows(at: [IndexPath(row: 0  , section: 0)], with: .automatic)

        
        
        DatabaseManager.shared.inserNewTask(by: user, task: taskList)
        self.tableView.reloadData()
        
    }
    
    
    private func doneTask(indexPath: IndexPath) {
        let currentTask = taskLists[indexPath.row]
        
        for task in currentTask.tasks {
            if task.isComplete == false {
                task.isComplete.toggle()
            }
            DatabaseManager.shared.isDoneTaskk(by: self.user, fromTask: currentTask, task: task)
        }
    }
    
    
    private func deleteFunc(at indexPath: IndexPath) {
        let task = taskLists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        for secTask in task.tasks {
            DatabaseManager.shared.deleteSecondTask(current: secTask, from: task.name, by: self.user)
            DatabaseManager.shared.deletePhoto(user: self.user.uid, taskList: task.name, currentTask: secTask.name)
            
        }
        
        DatabaseManager.shared.delete(current: task.name, by: self.user)
        
        self.tableView.reloadData()
    }
    
    
    func editPressed(at indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.editTaskAlert(with: "Изменить", and: "Хотите изменить цель?", and: indexPath)
        }
    
        
    }
    
    
    private func editTaskAlert(with title: String, and message: String, and indexPath: IndexPath){
        let taskText = taskLists[indexPath.row]
        let oldTask = taskLists[indexPath.row]
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let editAction = UIAlertAction(title: "Изменить", style: .default) { _ in
            guard let task = alert.textFields?.first?.text else { return }
            
            let newTask = TaskList(name: task)
            
            
            guard newTask.name != oldTask.name else { return }
            
            
            DispatchQueue.main.async {
                DatabaseManager.shared.inserNewTaskwithOldDate(by: self.user, task: newTask.name, oldTask: oldTask.name)
                
                for task in oldTask.tasks {
                    DatabaseManager.shared.deleteSecondTask(current: task, from: oldTask.name, by: self.user)
                    DatabaseManager.shared.deletePhoto(user: self.user.uid, taskList: oldTask.name, currentTask: task.name)
                    DatabaseManager.shared.insertSecondTask(by: self.user, fromTask: newTask.name, task: task.name, completionDate: task.completionDate)
                    
                    if task.imageURL != "" {
                    DatabaseManager.shared.downloadImage(user: self.user.uid,
                                                         fromTask: oldTask,
                                                         task: task) { result in
                        switch result {

                        case .success(let image):
    //                        self.ediImage = image
                            DatabaseManager.shared.upload(user: self.user.uid,
                                                          fromTask: newTask.name,
                                                          task: task.name,
                                                          photo: image) { result in
                                switch result {

                                case .success(let url):
                                    DatabaseManager.shared.insertPhoto(by: self.user,
                                                                       fromTask: newTask.name,
                                                                       task: task.name,
                                                                       completionDate: task.completionDate,
                                                                       isComplete: task.isComplete,
                                                                       url: url.absoluteString)

                                case .failure(let error):
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                    }


                }
            }
         
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                taskText.name = task
                self?.tableView.reloadData()
                self?.updateTaskList(self!.user, tableView: self!.tableView)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .destructive)
        
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = taskText.name
        }
        present(alert, animated: true)
    }
    
    
}



extension AllTasksViewController: AllTasksShowMenuDelegate {
   
    
    func showContextMenu(for button: UIButton, at indexPath: IndexPath) {
        button.menu = addMenuItems(at: indexPath)
        button.showsMenuAsPrimaryAction = true
    }
    
    
    func addMenuItems(at indexPath: IndexPath) -> UIMenu {
     
        let secondMenu = UIMenu(title: "" , options: .displayInline, children: [
            UIAction(title: "Удалить цель",
                     image: UIImage(systemName: "trash.fill")?.maskWithColor(color: .red),
                     handler: { (_) in
                self.deleteFunc(at: indexPath)
            })
        ])
        
        let menuItem = UIMenu(title: "", options: .displayInline, children: [
        
            UIAction(title: "Изменить",
                     image: UIImage(systemName: "scribble.variable")?.maskWithColor(color: .yellow),
                     handler: { (_) in
                self.editPressed(at: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
            }),
        
            UIAction(title: "Завершить", image: UIImage(systemName: "checkmark")?.maskWithColor(color: .green), handler: { (_) in
                self.doneTask(indexPath: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
            }),
            
            
            secondMenu
        ])
        
        return menuItem
    }
    

}








