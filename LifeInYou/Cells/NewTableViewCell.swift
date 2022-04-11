//
//  NewTableViewCell.swift
//  LifeInYou
//
//  Created by Roman on 09.04.2022.
//

import UIKit


typealias DidSelectClosure = ((_ tableIndex: Int?, _ collectionIndex: Int?) -> Void)


class NewTableViewCell: UITableViewCell {
    
    @IBOutlet var taskNameLabel: UILabel!
    @IBOutlet var tasksCollection: UICollectionView!
    
    @IBOutlet var progressOfDoneTasks: UIProgressView!
    
    @IBOutlet var progressOfDoneTasksLabel: UILabel!
    
  
    var didSelectClosure: DidSelectClosure?
    var index: Int?
    
    
    
    
    var taskList: TaskList! {
        didSet {
            taskNameLabel.text = taskList.name
            tasksCollection.reloadData()
        }
    }
    
    let sectionInserts = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)


    override func awakeFromNib() {
        super.awakeFromNib()
        
        tasksCollection.delegate = self
        tasksCollection.dataSource = self
        

    }

   
     
    
    
    
    func configure(with taskList: TaskList) {

        
        var current: [Task] {
            taskList.tasks.filter { $0.isComplete  }
        }
        
        let totalProgress = Float(current.count) / Float(taskList.tasks.count)
        progressOfDoneTasks.setProgress(totalProgress, animated: true)

        progressOfDoneTasksLabel.text = "\(current.count) из \(taskList.tasks.count)"
    }
    
   
    

}


extension NewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        taskList.tasks.count == 0 ? 0 : taskList.tasks.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! NewCollectionViewCell
        
        if taskList.tasks.count != 0 {
        cell.taskNameLabel.text = taskList.tasks[indexPath.row].name
        }
        cell.backgroundColor = UIColor(ciColor: CIColor(red: 147/255, green: 211/255, blue: 4/255, alpha: 0.4))
        cell.layer.cornerRadius = 20
        

        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "section", for: indexPath) as? SectionHeaderReusableView {
            
            
            return sectionHeader
        }
        
       
           return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectClosure?(index, indexPath.row)
    }
    
    
    
  
}


extension NewTableViewCell: UICollectionViewDelegateFlowLayout {
    
    
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



