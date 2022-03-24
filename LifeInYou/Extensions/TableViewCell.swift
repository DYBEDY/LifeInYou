//
//  TableViewCell.swift
//  LifeInYou
//
//  Created by Roman on 19.03.2022.
//

import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTasks = taskList.tasks.filter { task in
            task.isComplete == false
        }
        
        var completedTasks: [Task] {
            taskList.tasks
        }
        
            var content = defaultContentConfiguration()
            
            content.text = taskList.name
            
            if taskList.tasks.isEmpty {
                content.secondaryText = "0"
                accessoryType = .none
            } else if currentTasks.isEmpty {
                content.secondaryText = nil
                accessoryType = .checkmark
            } else {
                content.secondaryText = "\(completedTasks.count)"
                accessoryType = .none
            }
            
            contentConfiguration = content
        }
    }
    
    
    

