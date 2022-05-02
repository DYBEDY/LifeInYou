//
//  TasksCollectionViewCell.swift
//  LifeInYou
//
//  Created by Roman on 19.04.2022.
//

import UIKit
import Firebase
import FirebaseFirestore
import SkeletonView

class TasksCollectionViewCell: UICollectionViewCell {
    @IBOutlet var nameOfTaskLabel: UILabel! {
        didSet {
           
            nameOfTaskLabel.backgroundColor = UIColor(red: 47/255,
                                                      green: 79/255,
                                                      blue: 79/255,
                                                      alpha: 0.9)
            
            nameOfTaskLabel.layer.cornerRadius = 8
            nameOfTaskLabel.layer.masksToBounds = true
            nameOfTaskLabel.lineBreakMode = .byTruncatingTail
            nameOfTaskLabel.numberOfLines = 0
            nameOfTaskLabel.layer.borderWidth = 1
            nameOfTaskLabel.layer.borderColor = .init(red: 255/255, green: 250/255, blue: 205/255, alpha: 1)
            

            
        }
    }
    
    @IBOutlet var photoOfTask: UIImageView!
    

    
    @IBOutlet var viewWithContent: UIView! {
        didSet {
            viewWithContent.backgroundColor = UIColor(red: 25/255,
                                                      green: 25/255,
                                                      blue: 112/255,
                                                      alpha: 0)
        }
    }
        
    
    var imageURL: URL? {
        didSet {
            photoOfTask.image = nil
            updateImage()
        }
    }
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
    var taskList: TaskList!
    var task: Task!
    
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoOfTask.contentMode = .scaleAspectFill
        
        contentView.isSkeletonable = true
        contentView.showAnimatedGradientSkeleton()
        
        photoOfTask.isSkeletonable = true
        photoOfTask.showAnimatedGradientSkeleton()
        
        viewWithContent.isSkeletonable = true
        viewWithContent.showAnimatedGradientSkeleton()
       
    }
    
    
    
    
    private func updateImage() {
        guard let url = imageURL else { return }
        getImage(from: url) { result in
            switch result {
            case .success(let image):
                if url == self.imageURL {
                    self.photoOfTask.image = image
                    
                    self.contentView.stopSkeletonAnimation()
                    self.contentView.hideSkeleton()
                    
                    self.photoOfTask.stopAnimating()
                    self.photoOfTask.hideSkeleton()
                    
                    self.viewWithContent.stopSkeletonAnimation()
                    self.viewWithContent.hideSkeleton()
                }
               
            case .failure(let error):
               
                print(error)
            }
        }
    }
    
    
    private func getImage(from url: URL, completion: @escaping(Result<UIImage, Error>) -> Void) {
        // Get image from cache
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString ) {
            print("Image from cache: ", url.lastPathComponent)
            completion(.success(cachedImage))
            
            return
        }
        
        // Dowonload image from url
        DatabaseManager.shared.downloadImage(user: user.uid, fromTask: self.taskList, task: task) { result in
            switch result {
            case .success(let image):
                ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
                print("Image from network: ", url.lastPathComponent)
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))            }
        }
        
    }
    
}
