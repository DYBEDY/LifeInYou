//
//  WelcomeViewController.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import UIKit
import FirebaseAuth
import Firebase

class WelcomeViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var progressView: UIProgressView!
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var userNameTextField: UITextField!
    
    @IBOutlet var dateOfBirthdayTextFied: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var secondPasswordTextField: UITextField!
    
    @IBOutlet var inputPasswordLabel: UILabel!
    @IBOutlet var secondPasswordLabel: UILabel!
    
    
    
    @IBOutlet var registrationButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var menButton: UIButton!
    @IBOutlet var womenButton: UIButton!
    
    @IBOutlet var backBarButtonItem: UIBarButtonItem!
    
    
    
    private var steps = LoginSteps.takeAStep()
    private var currentStepIndex = 0
    
    private var isMen = false
    private var isWomen = false
    
    let birthdayDatePicker = UIDatePicker()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        nameTextField.delegate = self
        userNameTextField.delegate = self
        dateOfBirthdayTextFied.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        secondPasswordTextField.delegate = self
        
        nameTextField.returnKeyType = .next
        addDoneButtonTo(userNameTextField,dateOfBirthdayTextFied, secondPasswordTextField)
    }
    
    @IBAction func menButtonPressed() {
        isMen = true
        menButton.backgroundColor = .white
     
    }
    
    @IBAction func womenButtonPressed() {
        isWomen = true
        womenButton.backgroundColor = .white
        
    }
    
    
    
    
    
    @IBAction func registrButtonPressed() {
        guard let email = emailTextField.text, let password = passwordTextField.text,
                let userName = userNameTextField.text,
                let dateOfBirth = dateOfBirthdayTextFied.text,
              email != "", password != "" else { return }
        
        
        DatabaseManager.shared.validateNewUser(with: email) { [weak self] exists in
            guard !exists else {
                self?.showAlert(tittle: "Упс 😔", message: "Проверьте поля email и password")
                return
            }
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            if error == nil {
                if user != nil {
//                    guard let userID = Auth.auth().currentUser?.uid else { return }
                    self?.performSegue(withIdentifier: "fromRegistrSegue", sender: nil)

                    
                    let db = Firestore.firestore()
                    db.collection("users").document("\(user!.user.uid)").setData([
                        "email" : email,
                        "uid" : user!.user.uid,
                        "username": userName,
                        "dateofbirth": dateOfBirth
                    ])
//
                }
            } else {
                self?.showAlert(tittle: "Упс 😔", message: "Проверьте поля email и password")
            }
        }
    }
    
    
    
    
    
    
    @IBAction func nextButtonPressed() {
        getSecondScreen()
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        getPreviousScreen()
    }
    
    
}


// MARK: - Private methods

extension WelcomeViewController {
    private func setupUI() {
        let currentStep = steps[currentStepIndex]
        titleLabel.text = currentStep.steps.rawValue
        
        let totalProgress = Float(currentStepIndex) / Float(steps.count)
        progressView.setProgress(totalProgress, animated: true)
        
        showCurrentStep(for: currentStep.steps)
    }
    
    private func showCurrentStep(for title: Steps) {
        switch title {
        case .step1:
            applySettingsForFirstScreen()
        case .step2:
            applySettingsForSecondScreen()
        case .step3:
            applySettingsForThirdScreen()
        case .step4:
            applySettingForFourthScreen()
        }
    }
    
    private func applySettingsForFirstScreen() {
        backBarButtonItem.image = nil
        backBarButtonItem.title = ""
        
        titleLabel.isHidden = false
        
        descriptionLabel.isHidden = true
        
        nameTextField.isHidden = false
        userNameTextField.isHidden = false
        
        dateOfBirthdayTextFied.isHidden = true
        menButton.isHidden = true
        womenButton.isHidden = true
        
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        secondPasswordTextField.isHidden = true
        inputPasswordLabel.isHidden = true
        secondPasswordLabel.isHidden = true
        
        
        nextButton.isHidden = false
        registrationButton.isHidden = true
        
        title = "Знакомство"
    }
    
    private func applySettingsForSecondScreen() {
        backBarButtonItem.image = UIImage(systemName: "arrowshape.turn.up.backward")
        
        titleLabel.isHidden = false
        
        descriptionLabel.isHidden = true
        
        nameTextField.isHidden = true
        userNameTextField.isHidden = true
        
        dateOfBirthdayTextFied.isHidden = false
        birthdayPicker()
        
        menButton.isHidden = false
        womenButton.isHidden = false
        
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        secondPasswordTextField.isHidden = true
        inputPasswordLabel.isHidden = true
        secondPasswordLabel.isHidden = true
        
        nextButton.isHidden = false
        registrationButton.isHidden = true
        
        title = "Дата рождения"
    }
    
    private func applySettingsForThirdScreen() {
        backBarButtonItem.image = UIImage(systemName: "arrowshape.turn.up.backward")
        
        titleLabel.isHidden = false
        
        descriptionLabel.isHidden = true
        
        nameTextField.isHidden = true
        userNameTextField.isHidden = true
        
        dateOfBirthdayTextFied.isHidden = true
        menButton.isHidden = true
        womenButton.isHidden = true
        
        emailTextField.isHidden = false
        passwordTextField.isHidden = false
        secondPasswordTextField.isHidden = false
        inputPasswordLabel.isHidden = false
        secondPasswordLabel.isHidden = false
        
        nextButton.isHidden = false
        registrationButton.isHidden = true
        
        title = "Почта и пароль"
    }
    
    private func applySettingForFourthScreen() {
        backBarButtonItem.image = UIImage(systemName: "arrowshape.turn.up.backward")
        
        titleLabel.isHidden =  false
        if isMen == true {
            titleLabel.text = "По статистике мужчины живут в среднем 70 лет"
        } else {
            titleLabel.text = "По статистике женщины живут в среднем 79 лет"
        }
        
        descriptionLabel.isHidden = false
        if isMen == true {
        descriptionLabel.text =  "Ты прожил уже \(dateInterval(beginDate: dateOfBirthdayTextFied.text ?? "", endDate: getCurrentDay())) дней \n\n У тебя осталось \(dateIntervaForMen(currentAge: dateOfBirthdayTextFied.text ?? "")) дней, что бы ввыполнить все свои цели и прожить эту жизнь на полную "
        } else {
            descriptionLabel.text =  "Ты прожила уже \(dateInterval(beginDate: dateOfBirthdayTextFied.text ?? "", endDate: getCurrentDay())) дней \n\n У тебя осталось \(dateIntervaForWomen(currentAge: dateOfBirthdayTextFied.text ?? "")) дней, что бы выполнить все свои цели и прожить эту жизнь на полную катушку"
        }

        nameTextField.isHidden = true
        userNameTextField.isHidden = true
        
        dateOfBirthdayTextFied.isHidden = true
        menButton.isHidden = true
        womenButton.isHidden = true
        
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        secondPasswordTextField.isHidden = true
        inputPasswordLabel.isHidden = true
        secondPasswordLabel.isHidden = true
        
        nextButton.isHidden = true
        registrationButton.isHidden = false
        
        title = "Все готово для начала"
    }
    
    private func getSecondScreen() {
        if currentStepIndex == 0 {
            guard let name = nameTextField.text else { return }
            guard let userName = userNameTextField.text else { return }
            if name.isEmpty || userName.isEmpty {
                showAlert(tittle: "Упс 😔", message: "Поля не должны быть пустыми")
            } else {
                currentStepIndex += 1
            }
        } else if currentStepIndex == 1 {
            guard let date = dateOfBirthdayTextFied.text else { return }
            if date.isEmpty || isMen == false && isWomen == false  {
                showAlert(tittle: "Упс 😔", message: "Поля не должны быть пустыми")
            } else {
                currentStepIndex += 1
            }
        } else if currentStepIndex == 2 {
            guard let email = emailTextField.text else { return }
            guard let password = passwordTextField.text else { return }
            guard let secondPassword = secondPasswordTextField.text else { return }
            if password != secondPassword {
                showAlert(tittle: "Упс 😔", message: "Пароли не совпали")
            } else if email.isEmpty || password.isEmpty || secondPassword.isEmpty {
                showAlert(tittle: "Упс 😔", message: "Проверьте введенные поля")
            } else {
                currentStepIndex += 1
            }
        }
        
        if currentStepIndex < steps.count {
            setupUI()
            return
        }
    }
        
    private func getPreviousScreen() {
        if currentStepIndex == 1 {
            currentStepIndex -= 1
            setupUI()
        } else if currentStepIndex == 2 {
            currentStepIndex -= 1
            setupUI()
        } else if currentStepIndex == 3 {
            currentStepIndex -= 1
            setupUI()
        }
            
}
    

// MARK: - TextField settings

private func addDoneButtonTo(_ textFields: UITextField...) {

    let numberToolbar = UIToolbar()
    numberToolbar.sizeToFit()
    textFields.forEach { textField in
        switch textField {
        case userNameTextField: textField.inputAccessoryView = numberToolbar
        case dateOfBirthdayTextFied: textField.inputAccessoryView = numberToolbar
        case secondPasswordTextField: textField.inputAccessoryView = numberToolbar
        default: break
        }
    }
    
    let doneButton = UIBarButtonItem(title:"Done",
                                     style: .done,
                                     target: self,
                                     action: #selector(tapDone))

    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil,
                                        action: nil)

    numberToolbar.items = [flexBarButton, doneButton]
}

@objc private func tapDone() {
    if userNameTextField.isEditing || secondPasswordTextField.isEditing {
        if passwordTextField.text != secondPasswordTextField.text {
            showAlert(tittle: "Упс 😔", message: "Пароли не совпали")
            setupUI()
            view.endEditing(true)
        } else {
    currentStepIndex += 1
    setupUI()
    view.endEditing(true)
        }
    } else if dateOfBirthdayTextFied.isEditing {
        setupUI()
        view.endEditing(true)
    }
}

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches , with:event)
    view.endEditing(true)
}

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            userNameTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        default:
            secondPasswordTextField.becomeFirstResponder()
        }
        return true
    }
    
    
}

//MARK: - Alert Methods
extension WelcomeViewController {
    
private func showAlert(tittle: String, message: String) {
    let alert = UIAlertController(title: tittle, message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default)
    
    alert.addAction(alertAction)
    present(alert, animated: true)
    print("ok")
}
}

