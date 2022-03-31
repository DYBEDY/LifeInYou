//
//  ViewController.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import UIKit
import AVFoundation
import FirebaseAuth
import Firebase


class StartViewController: UIViewController {
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var videoLayer: UIView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var textStack: UIStackView!
    @IBOutlet var buttonStack: UIStackView!
    
    private var player: AVQueuePlayer!
    private var playerLayer: AVPlayerLayer!
    private var playerItem: AVPlayerItem!
    private var playerLooper: AVPlayerLooper!
   
    var activeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        playVideo()
        
//        emailTextField.delegate = self
//        passwordTextField.delegate = self
        
        infoLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
                if user != nil {
                    self?.performSegue(withIdentifier: "tabBarSegue", sender: nil)
                }
            }
        
        registerForKeyboardNotification()
       
    }
    
    
 
  

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playVideo()
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    
    

    
    @IBAction  func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: StartViewController) {
    do {
        try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
}
    

    
    
    
    @IBAction func registrButtonPressed() {
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(with: "Ошибка ввода")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil {
                self?.displayWarningLabel(with: "Error")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: "tabBarSegue", sender: nil)
                return
            }
            self?.displayWarningLabel(with: "Пользователь не найден")
        }
        
    }
    
    
    func displayWarningLabel(with text: String) {
        infoLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            self?.infoLabel.alpha = 1
        } completion: { [weak self] complete in
            self?.infoLabel.alpha = 0
        }

    }
    
//    func playVideo() {
//        guard let path = Bundle.main.path(forResource: "testVideo", ofType: "mp4") else { return }
//        let player = AVPlayer(url: URL(fileURLWithPath: path))
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = self.view.bounds
//        playerLayer.videoGravity = .resizeAspectFill
//        self.videoLayer.layer.addSublayer(playerLayer)
//        player.play()
//
//
//        videoLayer.bringSubviewToFront(textStack)
//        videoLayer.bringSubviewToFront(buttonStack)
//        videoLayer.bringSubviewToFront(infoLabel)
//
//
//}
 
    func playVideo() {
        guard let path = Bundle.main.path(forResource: "testVideo", ofType: "mp4") else { return }
        let pathURL = URL(fileURLWithPath: path)
        let duration = Int64( ( (Float64(CMTimeGetSeconds(AVAsset(url: pathURL).duration)) *  10.0) - 1) / 10.0 )

        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerItem = AVPlayerItem(url: pathURL)
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem,
                                      timeRange: CMTimeRange(start: CMTime.zero, end: CMTimeMake(value: duration, timescale: 1)) )
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = view.layer.bounds

        videoLayer.layer.addSublayer(playerLayer)
        player.play()

        videoLayer.bringSubviewToFront(textStack)
        videoLayer.bringSubviewToFront(buttonStack)
        videoLayer.bringSubviewToFront(infoLabel)
    }
    
    

}

//MARK: - Show content settings

extension StartViewController: UITextFieldDelegate {
   
    
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
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
    
    

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0

    }
    
   
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField :
            passwordTextField.becomeFirstResponder()
        default:
            emailTextField.becomeFirstResponder()
            
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        view.endEditing(true)
    }
}

extension UIResponder {
    private struct Static {
        static weak var responder: UIResponder?
    }
    
    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
    
    
}
