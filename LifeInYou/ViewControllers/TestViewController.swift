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
        completionDateofTask()
        setupActivityIndicator()
        setupVC()
       
        
//        if task?.imageURL != ""  {
//            downloadImage()
//        } else {
//            imageOfTask.image = UIImage(systemName: "photo.artframe")
//            activityIndicator.stopAnimating()
//        }
       
       
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
            delegate?.updateValue()
        }
        setupButton()
        
    }
    
    @IBAction func doneButtonPressed() {
        if doneButton.titleLabel?.text == "Добавить задачу" {
            insertNewTask()
//            insertNewPhoto()
            whenPushNewPhoto()
            dismiss(animated: true)
            delegate?.updateValue()
        } else {
            deleteTask()
            dismiss(animated: true)
            delegate?.updateValue()
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
    
    
    func upload(user: String, task: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("users").child(user).child("taskList").child(self.taskList.name).child(self.taskTextField.text ?? "")

        guard let imageData = imageOfTask.image?.jpegData(compressionQuality: 0.5) else { return }
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
    
    
    func whenPushNewPhoto() {
        if imageOfTask.image != UIImage(systemName: "photo.artframe") {
            insertNewPhoto()
        } else {
            return
        }
    }
    
    
    
    
    
    
    
    func downloadImage() {
        let ref = Storage.storage().reference().child("users").child(user.uid).child("taskList").child(self.taskList.name).child(self.task.name).storage.reference(forURL: task.imageURL)
       
        let megaByte = Int64(15 * 1024 * 1024)
        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else { return }
            let image = UIImage(data: imageData)
            self.imageOfTask.image = image
            print(("Вот ОНА ---> \(String(describing: self.task?.imageURL))") )
            self.activityIndicator.stopAnimating()
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


//MARK: - Work With Photo
extension TestViewController {
    func insertNewPhoto() {
        DatabaseManager.shared.upload(user: user.uid, fromTask: taskList.name, task: taskTextField.text ?? "", photo: imageOfTask.image ?? UIImage()) { result in
            switch result {

            case .success(let url):
//                DatabaseManager.shared.insertSecondTask(by: self.user, fromTask: self.taskList.name, task: self.taskTextField.text ?? "", completionDate: self.dateOfCompletionTextFied.text ?? "", url: url.absoluteString)
                
                DatabaseManager.shared.insertPhoto(by: self.user, fromTask: self.taskList.name, task: self.taskTextField.text ?? "", completionDate: self.dateOfCompletionTextFied.text ?? "", url: url.absoluteString)
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
//        guard let imageData = image.pngData() else { return }
//
//        let ref = Storage.storage().reference().child("users").child(user.uid).child("taskList").child(self.taskList.name).child(self.task.name)
//        ref.putData(imageData, metadata: nil) { _, error in
//            guard error == nil else {
//                print("faild tp upload")
//                return
//            }
//            ref.downloadURL { url, error in
//                guard let url = url else {
//
//                    return
//                }
//                let image = UIImage(data: imageData)
//                self.imageOfTask.image = image
//                print(url)
//                self.task.imageURL = url.absoluteString
//                self.db.collection("users").document("\(self.user.uid)").collection("taskList").document("\(self.taskList.name)").collection("tasks").document("\(self.task.name)").setData([
//                    "task" : self.task.name,
//                    "completionDate" : self.task.completionDate,
//                    "date" : self.task.date,
//                    "isComplete" : self.task.isComplete,
//                    "imageURL" : self.task.imageURL
//
//                ])
//            }
//
//        }
        imageOfTask.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
    




