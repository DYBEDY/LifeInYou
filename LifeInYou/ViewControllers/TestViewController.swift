//
//  NewTaskViewController.swift
//  LifeInYou
//
//  Created by Roman on 09.04.2022.
//

import UIKit
import Firebase
import FirebaseFirestore




class TestViewController: UIViewController {
    
       
    let db = Firestore.firestore()
    
    @IBOutlet var imageOfTask: UIImageView!
    
    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var dateOfCompletionTextFied: UITextField!
    
    @IBOutlet var nameOfTaskLabel: UILabel!
    
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var editButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    var actionForButton = true
    var delegate: AllTask2Delegate?
    var taskList: TaskList!
    var task: Task!
   
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
    let completionDatePicker = UIDatePicker()
  
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameOfTaskLabel.text = task?.name ?? ""
        taskTextField.text = task?.name ?? ""
        
        completionDateofTask()
        setupVC()
        
    
        
    }
    
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.updateValue()
    }
    
    
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
    }
    
    
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if editButton.titleLabel?.text == "Готово" {
            delegate?.updateValue()
            dismiss(animated: true)
        }
        setupButton()
        
    }
    
    @IBAction func doneButtonPressed() {
        if doneButton.titleLabel?.text == "Добавить задачу" {
            insertNewTask()
        } else {
            deleteTask()
        }
    }
    
    
    
    func setupVC() {
        if task?.name != nil {
            doneButton.isHidden = true
            taskTextField.isEnabled = false
            dateOfCompletionTextFied.isEnabled = false
            
        } else {
            doneButton.setTitle("Добавить задачу", for: .normal)
        }
    }
    
    func setupButton() {
        actionForButton.toggle()
        if actionForButton == false {
            editButton.setTitle("Готово", for: .normal)
            doneButton.isHidden = false
            doneButton.setImage(UIImage(systemName: "trash"), for: .normal)
            doneButton.setTitle("", for: .normal)
            taskTextField.isEnabled = true
            dateOfCompletionTextFied.isEnabled = true
            
        } else {
            editButton.setTitle("Изм.", for: .normal)
            doneButton.isHidden = true
            doneButton.setTitle("", for: .normal)
            taskTextField.isEnabled = false
            dateOfCompletionTextFied.isEnabled = false
            editTask()
        }
    }
    
}

    

extension TestViewController: UITextFieldDelegate {
    func completionDateofTask() {
        dateOfCompletionTextFied.inputView = completionDatePicker
        completionDatePicker.datePickerMode = .date
        completionDatePicker.preferredDatePickerStyle = .wheels
        
//        let minimumYear = Calendar.current.date(byAdding: .year, value: -80, to: Date())
        let minimumYear = Date()
        let maximumYaer = Calendar.current.date(byAdding: .year, value: 80, to: Date())
        
        completionDatePicker.minimumDate = minimumYear
        completionDatePicker.maximumDate = maximumYaer
        
        completionDatePicker.addTarget(self, action: #selector(completionDate), for: .valueChanged)
    }
    
    @objc func completionDate() {
        getDateOfCompletion()
    }
    
    private func getDateOfCompletion() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        dateOfCompletionTextFied.text = formatter.string(from: completionDatePicker.date)
    }
}


//MARK: - Work With FireStore
extension TestViewController {
    // insertNewTask
    
    func insertNewTask() {
        DatabaseManager.shared.insertSecondTask(by: user, fromTask: taskList.name, task: taskTextField.text ?? "", completionDate: dateOfCompletionTextFied.text ?? "")
        print(taskTextField.text ?? "zero")
    }
    
    func deleteTask() {
        DatabaseManager.shared.deleteTaskFromCollection(current: taskTextField.text ?? "", from: taskList.name, by: user)
    }
    
    func editTask() {
        DatabaseManager.shared.editCollectionTask(by: user, in: taskList.name, oldTask: task.name, newTask: taskTextField.text ?? "", completionDate: dateOfCompletionTextFied.text ?? "")
    }
}




    
    

    

