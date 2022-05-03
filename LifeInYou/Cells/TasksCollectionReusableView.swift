//
//  TasksCollectionReusableView.swift
//  LifeInYou
//
//  Created by Roman on 19.04.2022.
//

import UIKit

class TasksCollectionReusableView: UICollectionReusableView {
   
    
    
    @IBOutlet var addButtonText: UIButton!
    
   
    
   
    var delegateTest: AllTasksDelegate?
    var taskList: TaskList?
    var index: Int?
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
      
    }
 
    @IBAction func addButton() {
    
        delegateTest?.presentSecondView(taskList: taskList ?? TaskList(name: "Nope"))
    }
    
    
    

    
}
