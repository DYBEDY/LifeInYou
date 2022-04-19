//
//  TasksCollectionReusableView.swift
//  LifeInYou
//
//  Created by Roman on 19.04.2022.
//

import UIKit

class TasksCollectionReusableView: UICollectionReusableView, AllTasksDelegate {
    
    
    @IBOutlet var addButtonText: UIButton!
    
   
    
   
    var delegateTest: AllTasksDelegate?
    var taskList: TaskList?
    var index: Int?
 
    @IBAction func addButton() {
    
//        delegateTest?.moveOntheNextView(index ?? 0, taskList: taskList ?? TaskList(name: ""))
//        moveOntheNextView(taskList: taskList ?? TaskList(name: "NOPe"))
        presentSecondView(taskList: taskList ?? TaskList(name: "Nope"))
    }
    
    
    
    func presentSecondView(taskList: TaskList) {
        delegateTest?.presentSecondView(taskList: taskList)
    }
}
