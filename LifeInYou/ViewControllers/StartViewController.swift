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
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        playVideo()
        
       
        
        infoLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
                if user != nil {
                    self?.performSegue(withIdentifier: "tabBarSegue", sender: nil)
                }
            }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        playVideo()
    }
  
  
    func displayWarningLabel(with text: String) {
        infoLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            self?.infoLabel.alpha = 1
        } completion: { [weak self] complete in
            self?.infoLabel.alpha = 0
        }

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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

