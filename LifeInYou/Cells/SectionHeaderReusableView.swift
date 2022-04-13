//
//  SectionHeaderReusableView.swift
//  LifeInYou
//
//  Created by Roman on 09.04.2022.
//

import UIKit



class SectionHeaderReusableView: UICollectionReusableView, TaskListViewControllerDelegate {
   
    
   
    var delegateTest: TaskListViewControllerDelegate?
    var taskList: TaskList?
    var index: Int?
 
    @IBAction func addButton() {
    
//        delegateTest?.moveOntheNextView(index ?? 0, taskList: taskList ?? TaskList(name: ""))
        moveOntheNextView(index ?? 0, taskList: taskList ?? TaskList(name: "NOPe"))
    }
    
    func moveOntheNextView(_ index: Int, taskList: TaskList) {
        delegateTest?.moveOntheNextView(index, taskList: taskList)
    }
}


