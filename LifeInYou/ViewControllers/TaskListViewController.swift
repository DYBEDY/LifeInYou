//
//  TaskListViewController.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import UIKit
import Firebase
import FirebaseFirestore


class TaskListViewController: UITableViewController {
    var taskLists = Array<TaskList>()
    var currentUser: User!
    let db = Firestore.firestore()
    
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    private func updateTaskList(_ user: User) {
        db.collection("users").document("\(user.uid)").collection("taskList").order(by: "task", descending: true)
        db.collection("users").document("\(user.uid)").collection("taskList").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.taskLists = snapshot.documents.map { d in
                            return TaskList(name: d["task"] as? String ?? "")
                        }
                        self.tableView.reloadData()
                    }
                  
                }
            } else {
                
            }
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTaskList(user)
    }
    
    

    

    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksListCell", for: indexPath)
//        var content = cell.defaultContentConfiguration()
//        let taskList = taskLists[indexPath.row]
//        content.text = taskList.name
//
//
//        if taskList.isComplete == false {
//
//            cell.accessoryType = .none
//        } else {
//            cell.accessoryType = .checkmark
//        }
//
//
//        cell.contentConfiguration = content
        
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.deleteFunc(at: indexPath)

        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.editPressed(at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
            }
           
        
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
//            StorageManager.shared.done(taskList)
            self.doneTask(indexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
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





extension TaskListViewController {
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? "Edit List" : "New List"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new task list")

        alert.action(with: taskList) { newValue in
//            guard let currentUser = Auth.auth().currentUser else { return }
//            let user = User(user: currentUser)
//            if let taskList = taskList, let completion = completion {
//
//                completion()
//            } else {
            self.saveFunc(taskList: newValue)
            }
        present(alert, animated: true)
        }
           



    
    
    private func saveFunc(taskList: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let user = User(user: currentUser)
        let newTask = TaskList(name: taskList)
        self.taskLists.append(newTask)
        self.tableView.insertRows(at: [IndexPath(row: self.taskLists.count - 1, section: 0)], with: .automatic)
//        DatabaseManager.shared.insertNewTask(by: user, task: TaskList(name: newTask.name, userId: user.uid))
//        db.collection("users").document("\(user.uid)").collection("tasks").document("\(newTask.name)").setData([
//            "task" : newTask.name,
//            "userid": user.uid
//        ], merge: true)
          
        DatabaseManager.shared.inserNewTask(by: user, task: taskList)
        self.tableView.reloadData()

    }

    private func doneTask(indexPath: IndexPath) {
        let currentTask = taskLists[indexPath.row]
            guard let currentUser = Auth.auth().currentUser else { return }
            let user = User(user: currentUser)
//        currentTask.isComplete.toggle()
        DispatchQueue.main.async {
            self.db.collection("users").document("\(user.uid)").collection("tasks").document("\(currentTask.name)").setData([
                "task" : currentTask.name,
                "userid": user.uid
//                "isDone": currentTask.isComplete
            ], merge: true)
        }
    }
    
    
    
    
    
    
    
    private func deleteFunc(at indexPath: IndexPath) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let user = User(user: currentUser)
        let task = taskLists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        DatabaseManager.shared.delete(current: task, by: user)
        
        self.tableView.reloadData()
    }
    
    
    func editPressed(at indexPath: IndexPath) {
          editTaskAlert(with: "Edit", and: "Do you want to edit yours task?", and: indexPath)
          
      }
    
    
    private func editTaskAlert(with title: String, and message: String, and indexPath: IndexPath){
          let taskText = taskLists[indexPath.row]
          let oldTask = taskLists[indexPath.row]
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
          let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
              guard let currentUser = Auth.auth().currentUser else { return }
              let user = User(user: currentUser)
              
              guard let task = alert.textFields?.first?.text else { return }

              let newTask = TaskList(name: task)
              
              DatabaseManager.shared.editTask(by: user, oldTask: oldTask.name, newTask: newTask.name)
              taskText.name = task
              self.tableView.reloadData()

          }
        
        

          let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)


          alert.addAction(editAction)
          alert.addAction(cancelAction)
          alert.addTextField { textField in
              textField.text = taskText.name

          }
          present(alert, animated: true)
      }

    
}



