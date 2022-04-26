//
//  TasksCollectionViewCell.swift
//  LifeInYou
//
//  Created by Roman on 19.04.2022.
//

import UIKit

class TasksCollectionViewCell: UICollectionViewCell {
    @IBOutlet var nameOfTaskLabel: UILabel!
    
    @IBOutlet var photoOfTask: UIImageView!
    
    @IBOutlet var indicator: UIActivityIndicatorView! {
        didSet {
            indicator.color = .yellow
            indicator.startAnimating()
            indicator.hidesWhenStopped = true
        }
    }
    
    @IBOutlet var viewWithContent: UIView! {
        didSet {
            viewWithContent.backgroundColor = UIColor(red: 25/255,
                                                      green: 25/255,
                                                      blue: 112/255,
                                                      alpha: 0.3)
        }
    }
        
    
    
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoOfTask.contentMode = .scaleAspectFill
       
    }
    
    

    
    
}
