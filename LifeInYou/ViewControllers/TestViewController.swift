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
    
    var task: Task!
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(task.name)")
        
        
        
    }
    

    @IBAction func doneButtonPressed() {
    }
    

}
