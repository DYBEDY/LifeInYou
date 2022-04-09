//
//  TaskListViewController.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import UIKit
import Firebase
import FirebaseFirestore


class TaskListViewController: UITableViewController, UICollectionViewDelegate {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var taskLists: [TaskList] = []
    
    let db = Firestore.firestore()
    
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        
        updateTaskList(user)
     
    }
    
    
    private func updateTaskList(_ user: User) {
        self.db.collection("users").document("\(user.uid)").collection("taskList").order(by: "date", descending: false).getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.taskLists = snapshot.documents.map { d in
                            let task = TaskList(name: d["task"] as? String ?? "",
                                                date: d["date"] as? Date ?? .now
                            )

                            self.db.collection("users").document("\(user.uid)").collection("taskList").document("\(task.name)").collection("tasks").getDocuments { snapshot, error in
                                if error == nil {
                                    if let snapshot = snapshot {
                                        task.tasks = snapshot.documents.map { d in
                                            return Task(name: d["task"] as? String ?? "",
                                                        note: d["note"] as? String ?? "",
                                                        isComplete: d["isComplete"] as? Bool ?? false
                                            )
                                        }
                                        self.activityIndicator.isHidden = true
                                        self.activityIndicator.stopAnimating()
                                        self.tableView.reloadData()
                                        print("========\(self.taskLists.count)=======")
                                    }

                                }
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
        
        tableView.reloadData()

    }
    
    
    func moveOnTaskViewController(tIndex: Int, cIndex: Int, task: Task) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let newVC = storyBoard.instantiateViewController(withIdentifier: "TestViewController") as? TestViewController else { return }
        newVC.task = task
        
        navigationController?.pushViewController(newVC, animated: true)
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    
   

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksListCell", for: indexPath) as! NewTableViewCell
        let task = taskLists[indexPath.row]
        cell.configure(with: task)
        cell.taskList = task
//        cell.tasksCollection.delegate = self
//        cell.tasksCollection.dataSource = self
//        
        
        
        cell.didSelectClosure = { tabIndex, collIndex in
            let currentTask = task.tasks[collIndex ?? 0]
            self.moveOnTaskViewController(tIndex: indexPath.row, cIndex: collIndex ?? 0, task: currentTask)
            
            
        }
        
       
        return cell
    }
    



    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = taskLists[indexPath.row]
        var completedTasks: [Task] {
            task.tasks.filter { $0.isComplete  }
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            self.deleteFunc(at: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Изменить") { _, _, isDone in
            self.editPressed(at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            isDone(true)
        }
        
        
        let doneAction = UIContextualAction(style: .normal, title: "Готово") { _, _, isDone in
            //            StorageManager.shared.done(taskList)
            self.doneTask(indexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        editAction.image = UIImage(systemName: "pencil.circle.fill")
        doneAction.image = UIImage(systemName: "checkmark")
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        if task.tasks.count == completedTasks.count {
            return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        } else {
            return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
        }
    }
    
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        showAlert()
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let taskVC = segue.destination as? TaskViewController else { return }
        let taskList = taskLists[indexPath.row]
        taskVC.taskList = taskList
    }
    
}


//MARK: - Work with buttons
extension TaskListViewController {
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
        self.taskLists.append(newTask)
        self.tableView.insertRows(at: [IndexPath(row: self.taskLists.count - 1, section: 0)], with: .automatic)
        
        DatabaseManager.shared.inserNewTask(by: user, task: taskList)
        self.tableView.reloadData()
        
    }
    
    
    private func doneTask(indexPath: IndexPath) {
        let currentTask = taskLists[indexPath.row]
        
        for task in currentTask.tasks {
            if task.isComplete == false {
                task.isComplete.toggle()
            }
            DatabaseManager.shared.isDoneTask(by: self.user, fromTask: currentTask, task: task)
        }
    }
    
    
    private func deleteFunc(at indexPath: IndexPath) {
        let task = taskLists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        for secTask in task.tasks {
            DatabaseManager.shared.deleteSecondTask(current: secTask, from: task.name, by: self.user)
        }
        
        DatabaseManager.shared.delete(current: task.name, by: self.user)
        
        self.tableView.reloadData()
    }
    
    
    func editPressed(at indexPath: IndexPath) {
        editTaskAlert(with: "Изменить", and: "Хотите изменить цель?", and: indexPath)
        
    }
    
    
    private func editTaskAlert(with title: String, and message: String, and indexPath: IndexPath){
        let taskText = taskLists[indexPath.row]
        let oldTask = taskLists[indexPath.row]
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let editAction = UIAlertAction(title: "Изменить", style: .default) { _ in
            guard let task = alert.textFields?.first?.text else { return }
            
            let newTask = TaskList(name: task)
            
            DatabaseManager.shared.delete(current: oldTask.name, by: self.user)
            DatabaseManager.shared.inserNewTask(by: self.user, task: newTask.name)
            
            for task in oldTask.tasks {
                DatabaseManager.shared.insertSecondTask(by: self.user, fromTask: newTask.name, task: task.name, note: task.note)
                DatabaseManager.shared.deleteSecondTask(current: task, from: oldTask.name, by: self.user)
            }
            
            taskText.name = task
            self.tableView.reloadData()
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

