//
//  TaskViewController.swift
//  LifeInYou
//
//  Created by Roman on 20.03.2022.
//

import UIKit
import UIKit
import Firebase
import FirebaseFirestore



class TaskViewController: UITableViewController {
    let db = Firestore.firestore()
    var taskList: TaskList!

    var tasks: [Task] = []
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()

    private var currentTasks: [Task] {
        tasks.filter { !$0.isComplete }
    }

    private var completedTasks: [Task] {
        tasks.filter { $0.isComplete == true }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = taskList.name


        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        
        
        
    }
    
    
    
    
    
    
    
    
    
    private func updateTasks(_ user: User) {
        db.collection("users").document("\(user.uid)").collection("taskList").document("\(taskList.name)").collection("tasks").order(by: "task", descending: true)
        db.collection("users").document("\(user.uid)").collection("taskList").document("\(taskList.name)").collection("tasks").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.tasks = snapshot.documents.map { d in
                            print(d) // FIXME: d["name"]
//                            return Task(name: d["task"] as? String ?? "")
                            return Task(name: d["task"] as? String ?? "",
                                        note: d["note"] as? String ?? "",
                                        isComplete: d["isComplete"] as? Bool ?? true
                            )
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
        
        updateTasks(user)

    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasks", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [self] _, _, _ in
            DatabaseManager.shared.deleteSecondTask(current: task, from: self.taskList.name, by: self.user)
            tasks.removeAll { taskNew in
                task == taskNew
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.editPressed(at: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                isDone(true)
            }
            
            
        
        
        let doneTitle = indexPath.section == 0 ? "Done" : "Undone"
        
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { _, _, isDone in
//                    StorageManager.shared.done(task)
            let indexPathForCurrentTask = IndexPath(
                row: self.currentTasks.firstIndex(of: task) ?? 0,
                section: 0
            )
            let indexPathForCompletedTask = IndexPath(
                row: self.completedTasks.firstIndex(of: task) ?? 0,
                section: 1
            )

            let destinationIndexRow = indexPath.section == 0
            ? indexPathForCompletedTask
            : indexPathForCurrentTask
            tableView.moveRow(at: indexPath, to: destinationIndexRow)

            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func addButtonPressed() {
        showAlert()
        
    }
    
}

extension TaskViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { newValue, note in
            if let _ = task, let _ = completion {
                
            } else {
                self.saveTask(withName: newValue, andNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(name: name, note: note)

        tableView.performBatchUpdates {
            let rowIndex = IndexPath(row: tasks.firstIndex(of: task) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
            tasks.append(task)
            
        }
        
        DatabaseManager.shared.insertSecondTask(by: user, fromTask: taskList.name, task: task.name, note: task.note)
        tableView.reloadData()
        updateTasks(user)

}
    func editPressed(at indexPath: IndexPath) {
          editTaskAlert(with: "Edit", and: "Do you want to edit yours task?", and: indexPath)
          
      }
    
    
    private func editTaskAlert(with title: String, and message: String, and indexPath: IndexPath) {
//          let taskText = tasks[indexPath.row]
        let taskText = indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
         
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
          let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
              guard let task = alert.textFields?.first?.text else { return }
              
//              let newTask = Task(name: task)
              
//              DatabaseManager.shared.editTask(by: user, oldTask: oldTask.name, newTask: newTask.name)
              taskText.name = task
              
              self.tableView.reloadData()
//              self.updateTasks(self.user)

          }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)


        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = taskText.name
        }
        alert.addTextField { textField in
            textField.text = taskText.note
        }
        present(alert, animated: true)
    
}
    
    
    
//    private func deleteFunc(at indexPath: IndexPath) {
//        let task = tasks.remove(at: indexPath.row)
//        DatabaseManager.shared.deleteSecondTask(current: task, from: taskList.name, by: user)
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//
//        self.tableView.reloadData()
//    }
}
