//
//  NewTaskViewController.swift
//  LifeInYou
//
//  Created by Roman on 09.04.2022.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage



class TestViewController: UIViewController {
    
       
    let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    @IBOutlet var imageOfTask: UIImageView! {
        didSet {
            imageOfTask.layer.cornerRadius = 20
            imageOfTask.contentMode = .scaleAspectFill
            
        }
    }
        
    
    
    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var dateOfCompletionTextFied: UITextField!
    
//    @IBOutlet var nameOfTaskLabel: UILabel!
    
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var editButton: UIButton!
    
    @IBOutlet var addPhotoButton: UIButton!
    
  
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
    let completionDatePicker = UIDatePicker()
  
    var actionForButton = true
    
    var delegate: AllTask2Delegate?
    var taskList: TaskList!
    var task: Task!
    var url: String?
    
    var activityIndicator = UIActivityIndicatorView()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTextField.text = task?.name ?? ""
        dateOfCompletionTextFied.text = task?.completionDate ?? ""
        completionDateofTask()
        setupActivityIndicator()
        setupVC()
        
        
        registerForKeyboardNotification()
        taskTextField.delegate = self
        dateOfCompletionTextFied.delegate = self
        
        
        
    }
    
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.updateValue()
    }
    
    
    
 
   
    
    
    @IBAction func addPhotoPressed() {
      let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if editButton.titleLabel?.text == "Готово" {
//            delegate?.updateValue()
        }
        setupButton()
        
    }
    
    @IBAction func doneButtonPressed() {
        if doneButton.titleLabel?.text == "Добавить задачу" {
            insertNewTask()
            delegate?.updateValue()
            activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            activityIndicator.center = view.center
            activityIndicator.backgroundColor = .gray
            activityIndicator.layer.cornerRadius = 5
            activityIndicator.startAnimating()
            activityIndicator.hidesWhenStopped = true
            view.addSubview(activityIndicator)
            self.view.addSubview(self.activityIndicator)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
               
                self?.dismiss(animated: true)
                
            }
            
            
        } else {
            deleteTask()
            delegate?.updateValue()
            dismiss(animated: true)
        }
    }
    
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        
        activityIndicator.center = imageOfTask.center
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    
    func setupVC() {
        if task?.name != nil && task?.imageURL != "" {
            doneButton.isHidden = true
            taskTextField.isEnabled = false
            dateOfCompletionTextFied.isEnabled = false
            addPhotoButton.isHidden = true
            downloadImage()
        } else if task?.name != nil && task?.imageURL == ""  {
            doneButton.isHidden = true
            addPhotoButton.isHidden = true
            taskTextField.isEnabled = false
            dateOfCompletionTextFied.isEnabled = false
            
            imageOfTask.image = UIImage(systemName: "photo.artframe")
            self.activityIndicator.stopAnimating()
        } else {
            doneButton.setTitle("Добавить задачу", for: .normal)
            imageOfTask.image = UIImage(systemName: "photo.artframe")
            self.activityIndicator.stopAnimating()
            
        }
    }
    
    func setupButton() {
        actionForButton.toggle()
        if actionForButton == false {
            editButton.setTitle("Готово", for: .normal)
            doneButton.isHidden = false
            doneButton.setImage(UIImage(systemName: "trash"), for: .normal)
            doneButton.imageView?.tintColor = .red
            doneButton.setTitle("", for: .normal)
            addPhotoButton.isHidden = false
            taskTextField.isEnabled = true
            dateOfCompletionTextFied.isEnabled = true
            
        } else {
            editButton.setTitle("Изм.", for: .normal)
            doneButton.isHidden = true
            doneButton.setTitle("", for: .normal)
            taskTextField.isEnabled = false
            dateOfCompletionTextFied.isEnabled = false
            addPhotoButton.isHidden = true
            
            editTask()
            whenPushNewPhoto()

        }
    }
    
    
    
    func whenPushNewPhoto() {
        if imageOfTask.image != UIImage(systemName: "photo.artframe") {
            insertNewPhoto()
        } else {
            return
        }
    }
    
    
   
    
   
    
    
}

    



//MARK: - Work With FireStore
extension TestViewController {
    
    func insertNewTask() {
        DatabaseManager.shared.insertSecondTask(by: user, fromTask: taskList.name, task: taskTextField.text ?? "", completionDate: dateOfCompletionTextFied.text ?? "")
        whenPushNewPhoto()
        
    }
    
    func deleteTask() {
        DatabaseManager.shared.deleteTaskFromCollection(current: taskTextField.text ?? "", from: taskList.name, by: user)
        deleteImage()
    }
    
    func editTask() {
        DatabaseManager.shared.editCollectionTask(by: user, in: taskList.name, oldTask: task.name, newTask: taskTextField.text ?? "", completionDate: dateOfCompletionTextFied.text ?? "")
            self.editImage()
       
        
        
    }
}


//MARK: - Work With Photo
extension TestViewController {
    func insertNewPhoto() {
        DatabaseManager.shared.upload(user: user.uid, fromTask: taskList.name, task: taskTextField.text ?? "", photo: imageOfTask.image ?? UIImage()) { result in
            switch result {
            case .success(let url):
                DatabaseManager.shared.insertPhoto(by: self.user, fromTask: self.taskList.name, task: self.taskTextField.text ?? "", completionDate: self.dateOfCompletionTextFied.text ?? "", url: url.absoluteString)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteImage() {
        DatabaseManager.shared.deletePhoto(user: user.uid, taskList: taskList.name, currentTask: task.name)
    }
    
    
    func editImage() {
        DatabaseManager.shared.deletePhoto(user: user.uid, taskList: taskList.name, currentTask: task.name)
        DatabaseManager.shared.upload(user: user.uid, fromTask: taskList.name, task: taskTextField.text ?? "", photo: imageOfTask.image ?? UIImage()) { result in
            switch result {
            case .success(let url):
                DatabaseManager.shared.insertPhoto(by: self.user, fromTask: self.taskList.name, task: self.taskTextField.text ?? "", completionDate: self.dateOfCompletionTextFied.text ?? "", url: url.absoluteString)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func downloadImage() {
        DatabaseManager.shared.downloadImage(user: user.uid, fromTask: self.taskList, task: self.task) { result in
            switch result {
            case .success(let image):
                self.imageOfTask.image = image
                self.activityIndicator.stopAnimating()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
}
    
    
//MARK: - UIImagePickerController

extension TestViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        imageOfTask.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
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
    
    //MARK: - Move TF when tapped
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShoww(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidee(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    @objc func keyboardWillShoww(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextField  else { return }
        
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            view.frame.origin.y = newFrameY
            
        }
        
    }
    
    
    
    @objc func keyboardWillHidee(sender: NSNotification) {
        self.view.frame.origin.y = 0
        
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case taskTextField :
            dateOfCompletionTextFied.becomeFirstResponder()
        default:
            taskTextField.becomeFirstResponder()
            
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        view.endEditing(true)
    }
}




