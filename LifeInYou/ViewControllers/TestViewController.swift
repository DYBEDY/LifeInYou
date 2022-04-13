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
    
    
    var taskList: TaskList?
    var task: Task?
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
    let completionDatePicker = UIDatePicker()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameOfTaskLabel.text = task?.name ?? ""
        taskTextField.text = task?.name ?? ""
        
        if task?.name == nil {
            doneButton.setTitle("Добавить задачу", for: .normal)
        }
        
        dateOfCompletionTextFied.delegate = self
        completionDateofTask()
        
        
        print("\(taskList?.name ?? "----")")
       
    }
    

    @IBAction func doneButtonPressed() {
//      insertNewTask()
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
    
//    func insertNewTask() {
//        DatabaseManager.shared.insertNewtask(by: user, fromTask: taskList.name, task: taskTextField.text ?? "")
//    }
    
    
    
}



