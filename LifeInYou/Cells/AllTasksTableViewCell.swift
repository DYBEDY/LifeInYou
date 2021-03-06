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



class AllTasksTableViewCell: UITableViewCell, AllTasksDelegate {
   
    
    
    @IBOutlet var taskNameLabel: UILabel!
    @IBOutlet var progressOfCompletionTasks: UIProgressView!
    @IBOutlet var completionTasksLabel: UILabel!
    @IBOutlet var collectionOfTasks: UICollectionView!
    @IBOutlet var dateOfCreatedTaskLabel: UILabel!
    
    @IBOutlet var showContextMenuButton: UIButton!
    
    var didSelectClosure: DidSelectClosure?
    var index: Int?
    var indexPath: IndexPath!
    
    var bool = false
    
    var delegate: AllTasksDelegate?

    
    let dateFormatter = DateFormatter()
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
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 15, left: 4, bottom: 15, right: 4))
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        
       
    }

    

    func configure(with taskList: TaskList) {
        var current: [Task] {
            taskList.tasks.filter { $0.isComplete  }
        }

        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateOfask = dateFormatter.string(from: taskList.date)
        dateOfCreatedTaskLabel.text = "???????? ??????????????: \(dateOfask)"
       
       
        let totalProgress = Float(current.count) / Float(taskList.tasks.count)
        progressOfCompletionTasks.setProgress(totalProgress, animated: true)
        completionTasksLabel.text = "\(current.count) ???? \(taskList.tasks.count)"
        
        
        
        delegate?.showContextMenu(for: showContextMenuButton, at: indexPath)
        
        
    }
    

    
//MARK: - Delegate methods
    
    func presentSecondView(taskList: TaskList) {
        delegate?.presentSecondView(taskList: taskList)
        
    }
    
  
    
}

//MARK: - Collection Methods

extension AllTasksTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        taskList.tasks.count == 0 ? 0 : taskList.tasks.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TasksCollectionViewCell", for: indexPath) as! TasksCollectionViewCell
        let task = taskList.tasks[indexPath.item]
        cell.taskList = taskList
        cell.task = task
        cell.imageURL = URL(string: task.imageURL)
        
        
        if taskList.tasks.count != 0 {
            cell.nameOfTaskLabel.text = task.name
        }
        
    
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
    
    
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        if bool == true {
//            return CGSize(width: 0, height: 0)
//        } else {
//            return CGSize(width: 50, height: 50)
//        }
//
//
//    }
//
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectClosure?(index, indexPath.row)
       
    }
    
   
}


extension AllTasksTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 1.2
        let paddingWidth = 20 * (itemsPerRow )
        let avalibleWidth = ( collectionView.frame.width - 20 ) - paddingWidth
        let widthPerItem = avalibleWidth / itemsPerRow
        let hightPerItem = (widthPerItem / 2) + 50

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












