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
import SkeletonView



class TestViewController: UIViewController {
    
       
    let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    @IBOutlet var imageOfTask: UIImageView! {
        didSet {
            imageOfTask.layer.cornerRadius = 20
            imageOfTask.contentMode = .scaleAspectFill
            
        }
    }
        
    
    @IBOutlet var viewForSkeleton: UIView! {
        didSet {
            viewForSkeleton.backgroundColor = UIColor(red: 0,
                                                      green: 0,
                                                      blue: 0,
                                                      alpha: 0)
            viewForSkeleton.bringSubviewToFront(addPhotoButton)
        }
        
    }
    
    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var dateOfCompletionTextFied: UITextField!
    
//    @IBOutlet var nameOfTaskLabel: UILabel!
    
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var editButton: UIButton!
    
    @IBOutlet var addPhotoButton: UIButton!
    
    @IBOutlet var isCompleteControl: UISegmentedControl! {
        didSet {
            isCompleteControl.setTitle("В работе", forSegmentAt: 0)
            isCompleteControl.setTitle("Выполнена", forSegmentAt: 1)
            
            if isComplete == true {
                isCompleteControl.selectedSegmentIndex = 1
            } else {
                isCompleteControl.selectedSegmentIndex = 0
            }
        }
    }
    
    @IBOutlet var daysToCompletionLabel: UILabel!
    
    @IBOutlet var completionInfoStackView: UIStackView!
    
    @IBOutlet var nameOfTaskLabel: UILabel!
    
    @IBOutlet var completionDateOfTaskLAbel: UILabel!
    
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var daysTextLabel: UILabel!
    
    
    @IBOutlet var lineView: UIView!
    
    
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
    
    var imageURL: URL? {
        didSet {
            imageOfTask.image = nil
            updateImage()
        }
    }
    
    
    let completionDatePicker = UIDatePicker()
  
    var actionForButton = true
    
    var delegate: AllTasksDelegate?
    var taskList: TaskList!
    var task: Task!
    var url: String?
    
    var isComplete: Bool!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTextField.text = task?.name ?? ""
        dateOfCompletionTextFied.text = task?.completionDate ?? ""
        daysToCompletionLabel.text = getCountOfDaysToFinishTask(daysToFinish: dateOfCompletionTextFied.text ?? "x")
        completionDateofTask()
       
        setupVC()
        
        
        registerForKeyboardNotification()
        taskTextField.delegate = self
        dateOfCompletionTextFied.delegate = self
        
       
    }
    
   

    
 
    @IBAction func isCompleteTapped(_ sender: UISegmentedControl) {
        isComplete.toggle()
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
        } else {
            deleteTask()
            delegate?.updateValue()
            dismiss(animated: true)
        }
    }
    
    
    
    func setupVC() {
        if task?.name != nil && task?.imageURL != "" {
            doneButton.isHidden = true
            isCompleteControl.isHidden = true
            whenShowStackView()
            taskTextField.isEnabled = false
            dateOfCompletionTextFied.isEnabled = false
            addPhotoButton.isHidden = true
            imageURL = URL(string: task.imageURL)
            updateImage()
        } else if task?.name != nil && task?.imageURL == ""  {
            doneButton.isHidden = true
            isCompleteControl.isHidden = true
            whenShowStackView()
            addPhotoButton.isHidden = true
            
            taskTextField.isEnabled = false
            dateOfCompletionTextFied.isEnabled = false
            
            imageOfTask.image = UIImage(systemName: "photo.artframe")
        } else {
            doneButton.setTitle("Добавить задачу", for: .normal)
            imageOfTask.image = UIImage(systemName: "photo.artframe")
            isCompleteControl.isHidden = true
            editButton.isHidden = true
            completionInfoStackView.isHidden = true
            
            
        }
    }
    
    func setupButton() {
        actionForButton.toggle()
        if actionForButton == false {
            editButton.setTitle("Готово", for: .normal)
            doneButton.isHidden = false
            isCompleteControl.isHidden = false
            doneButton.setImage(UIImage(systemName: "trash"), for: .normal)
            doneButton.imageView?.tintColor = .red
            doneButton.setTitle("", for: .normal)
            addPhotoButton.isHidden = false
            completionInfoStackView.isHidden = true
            taskTextField.isEnabled = true
            dateOfCompletionTextFied.isEnabled = true
            
        } else {
            editButton.setTitle("Изм.", for: .normal)
            doneButton.isHidden = true
            doneButton.setTitle("", for: .normal)
            taskTextField.isEnabled = false
            dateOfCompletionTextFied.isEnabled = false
            addPhotoButton.isHidden = true
            isCompleteControl.isHidden = true
            completionInfoStackView.isHidden = false
    
            daysToCompletionLabel.text = getCountOfDaysToFinishTask(daysToFinish: dateOfCompletionTextFied.text ?? "x")
            
            editTask()
            
        }
    }
    
    
    
    func whenEditImage() {
        if imageOfTask.image != UIImage(systemName: "photo.artframe") {
            editImage()
        } else {
            return
        }
    }
    
    func whenShowStackView() {
        if daysToCompletionLabel.text != "" {
            completionInfoStackView.isHidden = false
        } else {
            completionInfoStackView.isHidden = true
        }
    }
    
   
    
    
}

    



//MARK: - Work With FireStore
extension TestViewController {
    
    func insertNewTask() {
        DatabaseManager.shared.insertSecondTask(by: user,
                                                fromTask: taskList.name,
                                                task: taskTextField.text ?? "",
                                                completionDate: dateOfCompletionTextFied.text ?? "")

        insertNewPhoto()
        
    }
    
    func deleteTask() {
        DatabaseManager.shared.deleteTaskFromCollection(current: taskTextField.text ?? "",
                                                        from: taskList.name,
                                                        by: user)
        deleteImage()
    }
    
    func editTask() {
        DatabaseManager.shared.editCollectionTask(by: user,
                                                  in: taskList.name,
                                                  oldTask: task.name,
                                                  newTask: taskTextField.text ?? "",
                                                  completionDate: dateOfCompletionTextFied.text ?? "",
                                                  isComplete: isComplete)
        
        editImage()
      
        
    }
    
}


//MARK: - Work With Photo
extension TestViewController {
    func insertNewPhoto() {
        startSkeletonAnimation(for: taskTextField,
                               dateOfCompletionTextFied,
                               doneButton,
                               editButton,
                               addPhotoButton,
                               isCompleteControl,
                               lineView,
                               daysToCompletionLabel,
                               nameOfTaskLabel,
                               completionDateOfTaskLAbel,
                               infoLabel,
                               completionInfoStackView,
                               viewForSkeleton,
                               daysTextLabel)
        
        DatabaseManager.shared.upload(user: user.uid, fromTask: taskList.name, task: taskTextField.text ?? "", photo: imageOfTask.image ?? UIImage()) { result in
            switch result {
            case .success(let url):
                if self.imageOfTask.image != UIImage(systemName: "photo.artframe") && self.imageOfTask.image != nil {
                DatabaseManager.shared.insertPhoto(by: self.user, fromTask: self.taskList.name, task: self.taskTextField.text ?? "", completionDate: self.dateOfCompletionTextFied.text ?? "", isComplete: self.isComplete, url: url.absoluteString)
                } else {
                    self.imageOfTask.image = UIImage(systemName: "photo.artframe")
                    
                 
                }
             
                self.delegate?.updateValue()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.startSkeletonAnimation(for: self.taskTextField,
                                                self.dateOfCompletionTextFied,
                                                self.doneButton,
                                                self.editButton,
                                                self.addPhotoButton,
                                                self.isCompleteControl,
                                                self.lineView,
                                                self.daysToCompletionLabel,
                                                self.nameOfTaskLabel,
                                                self.completionDateOfTaskLAbel,
                                                self.infoLabel,
                                                self.completionInfoStackView,
                                                self.viewForSkeleton,
                                                self.daysTextLabel)
                    
                    self.dismiss(animated: true)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteImage() {
        DatabaseManager.shared.deletePhoto(user: user.uid, taskList: taskList.name, currentTask: task.name)
    }
    
    
    func editImage() {
        startSkeletonAnimation(for: taskTextField,
                               dateOfCompletionTextFied,
                               doneButton,
                               editButton,
                               addPhotoButton,
                               isCompleteControl,
                               lineView,
                               daysToCompletionLabel,
                               nameOfTaskLabel,
                               completionDateOfTaskLAbel,
                               infoLabel,
                               completionInfoStackView,
                               viewForSkeleton,
                               daysTextLabel)
        
        DatabaseManager.shared.deletePhoto(user: user.uid, taskList: taskList.name, currentTask: task.name)
        DatabaseManager.shared.upload(user: user.uid, fromTask: taskList.name, task: taskTextField.text ?? "", photo: imageOfTask.image ?? UIImage()) { result in
            switch result {
            case .success(let url):
                if self.imageOfTask.image != UIImage(systemName: "photo.artframe") && self.imageOfTask.image != nil {
                DatabaseManager.shared.insertPhoto(by: self.user, fromTask: self.taskList.name, task: self.taskTextField.text ?? "", completionDate: self.dateOfCompletionTextFied.text ?? "", isComplete: self.isComplete, url: url.absoluteString)
                } else {
                    self.delegate?.updateValue()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.imageOfTask.image = UIImage(systemName: "photo.artframe")
                        self.startSkeletonAnimation(for: self.taskTextField,
                                                    self.dateOfCompletionTextFied,
                                                    self.doneButton,
                                                    self.editButton,
                                                    self.addPhotoButton,
                                                    self.isCompleteControl,
                                                    self.lineView,
                                                    self.daysToCompletionLabel,
                                                    self.nameOfTaskLabel,
                                                    self.completionDateOfTaskLAbel,
                                                    self.infoLabel,
                                                    self.completionInfoStackView,
                                                    self.viewForSkeleton,
                                                    self.daysTextLabel)
                        
                        
                        self.dismiss(animated: true)
                    })
                }
                
                self.delegate?.updateValue()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.startSkeletonAnimation(for: self.taskTextField,
                                                self.dateOfCompletionTextFied,
                                                self.doneButton,
                                                self.editButton,
                                                self.addPhotoButton,
                                                self.isCompleteControl,
                                                self.lineView,
                                                self.daysToCompletionLabel,
                                                self.nameOfTaskLabel,
                                                self.completionDateOfTaskLAbel,
                                                self.infoLabel,
                                                self.completionInfoStackView,
                                                self.viewForSkeleton,
                                                self.daysTextLabel)
                    
                    self.dismiss(animated: true)
                })
                    
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
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getImage(from url: URL, completion: @escaping(Result<UIImage, Error>) -> Void) {
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            print("Image from cache --- \(url.lastPathComponent)")
            completion(.success(cachedImage))
            
            return
        }
        
        DatabaseManager.shared.downloadImage(user: user.uid, fromTask: taskList, task: task) { result in
            switch result {
                
            case .success(let image):
                ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
                print("Image from network --- \(url.lastPathComponent)")
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func updateImage() {
        guard let url = imageURL else { return }
        getImage(from: url) { result in
            switch result {
            case .success(let image):
                if url == self.imageURL {
                    self.imageOfTask.image = image
                }
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
        


        let minimumYear = Date()
        let maximumYaer = Calendar.current.date(byAdding: .year, value: 80, to: Date())
        
        completionDatePicker.minimumDate = minimumYear
        completionDatePicker.maximumDate = maximumYaer
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let dateOfFinish = dateFormatter.date(from: dateOfCompletionTextFied.text ?? "")
        
        if dateOfCompletionTextFied.text != "" {
            completionDatePicker.date = dateOfFinish ?? Date()
        } else {
            completionDatePicker.date = Date()
        }
        
        
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
    
    
    
    func getCountOfDaysToFinishTask(daysToFinish: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        guard let dateOfFinish = dateFormatter.date(from: dateOfCompletionTextFied.text ?? "") else { return ""}
        let dateInerval = Calendar.current.dateComponents([.day], from: Date(), to: dateOfFinish)
        guard let days = dateInerval.day else { return ""}
        let countOfDays = "\(days)"
        return countOfDays
        
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
        
        if textFieldBottomY >= keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            self.view.frame.origin.y = newFrameY
            
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




extension TestViewController {
    
    func startSkeletonAnimation(for items: UIView...) {
        let gradient = SkeletonGradient(baseColor: UIColor.peterRiver)
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topBottom)
        SkeletonAppearance.default.multilineHeight = 20
    
        for item in items {
            item.skeletonCornerRadius = 10
            item.isSkeletonable = true
            item.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation, transition: .none)
        }
    }
    
    func stopSkeletonAnimation(for items: UIView...) {
        for item in items {
            
            item.stopSkeletonAnimation()
            item.hideSkeleton()
        }
    }
    
    
}
