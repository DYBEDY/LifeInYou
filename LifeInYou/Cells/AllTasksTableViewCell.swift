//
//  AllTasksTableViewCell.swift
//  LifeInYou
//
//  Created by Roman on 19.04.2022.
//

import UIKit
import Firebase
import FirebaseFirestore

typealias DidSelectClosure = ((_ tableIndex: Int?, _ collectionIndex: Int?) -> Void)



class AllTasksTableViewCell: UITableViewCell, AllTasksDelegate, AllTask3Delegate {
    func update() {
        cellDelegate?.update()
        print("KOKOKO")
    }
    
    
    
    
    
    @IBOutlet var taskNameLabel: UILabel!
    @IBOutlet var progressOfCompletionTasks: UIProgressView!
    @IBOutlet var completionTasksLabel: UILabel!
    @IBOutlet var collectionOfTasks: UICollectionView!
    
    
    var didSelectClosure: DidSelectClosure?
    var index: Int?
    
    var delegate: AllTasksDelegate?
    var cellDelegate: AllTask3Delegate?
    
    let sectionInserts = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    var taskList: TaskList! {
        didSet {
            taskNameLabel.text = taskList.name
            collectionOfTasks.reloadData()
        }
    }
    
    let user: User! = {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return User(user: currentUser)
    }()
    
   

    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionOfTasks.delegate = self
        collectionOfTasks.dataSource = self
       
    }

    

    
    
    func configure(with taskList: TaskList) {
        var current: [Task] {
            taskList.tasks.filter { $0.isComplete  }
        }
        
        
        
        let totalProgress = Float(current.count) / Float(taskList.tasks.count)
        progressOfCompletionTasks.setProgress(totalProgress, animated: true)
        completionTasksLabel.text = "\(current.count) из \(taskList.tasks.count)"
    }
    

    func presentSecondView(taskList: TaskList) {
        delegate?.presentSecondView(taskList: taskList)
        
    }
    
    

    
}

extension AllTasksTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        taskList.tasks.count == 0 ? 0 : taskList.tasks.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TasksCollectionViewCell", for: indexPath) as! TasksCollectionViewCell
        let task = taskList.tasks[indexPath.item]
        
       
        
        if taskList.tasks.count != 0 {
            cell.nameOfTaskLabel.text = task.name
        }
        
        if task.imageURL != "" {
            DatabaseManager.shared.downloadImage(user: user.uid, fromTask: self.taskList, task: task) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        cell.photoOfTask.image = image
                        cell.indicator.stopAnimating()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            cell.photoOfTask.image = nil
            cell.indicator.stopAnimating()
        }
        
//        cell.backgroundColor = UIColor(ciColor: CIColor(red: 147/255, green: 211/255, blue: 4/255, alpha: 0.4))
        cell.layer.cornerRadius = 20
        cell.layer.borderWidth = 5
        cell.layer.borderColor = .init(red: 255/255, green: 250/255, blue: 205/255, alpha: 1)
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TasksCollectionReusableView", for: indexPath) as? TasksCollectionReusableView {
            sectionHeader.delegateTest = self
            
            sectionHeader.taskList = taskList
            
            return sectionHeader
        }
        
        return UICollectionReusableView()
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectClosure?(index, indexPath.row)
       
    }
    
   
}


extension AllTasksTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 1.2
        let paddingWidth = 20 * (itemsPerRow )
        let avalibleWidth = ( collectionView.frame.width - 25 ) - paddingWidth
        let widthPerItem = avalibleWidth / itemsPerRow
        let hightPerItem = (widthPerItem / 2) + 10

        return CGSize(width: widthPerItem, height: hightPerItem)
//        CGSize(width: 300, height: 150)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInserts
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInserts.left

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        19
    }
}
