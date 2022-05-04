//
//  ExtensionProtocol.swift
//  LifeInYou
//
//  Created by Roman on 04.05.2022.
//

import UIKit


protocol AllTasksDelegate {
    
    func presentSecondView(taskList: TaskList)
    
    func updateValue()

    func showContextMenu(for button: UIButton, at indexPath: IndexPath)
        
    
}

extension AllTasksDelegate {
    
    func presentSecondView(taskList: TaskList) {
        
    }
    
    func updateValue() {
        
    }

    func showContextMenu(for button: UIButton, at indexPath: IndexPath) {
        
    }
    
  
    
}
