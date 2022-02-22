//
//  ExtensionWorkWithDate.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import UIKit

extension WelcomeViewController: UITextFieldDelegate {
    
    func birthdayPicker() {
        dateOfBirthdayTextFied.inputView = birthdayDatePicker
        birthdayDatePicker.datePickerMode = .date
        birthdayDatePicker.preferredDatePickerStyle = .wheels
        
        let minimumYear = Calendar.current.date(byAdding: .year, value: -80, to: Date())
        let maximumYaer = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        
        birthdayDatePicker.minimumDate = minimumYear
        birthdayDatePicker.maximumDate = maximumYaer
        
        birthdayDatePicker.addTarget(self, action: #selector(dateChangedBirth), for: .valueChanged)
    }
    
    @objc func dateChangedBirth() {
        getBirthDateFromPicker()
    }
    
    private func getBirthDateFromPicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        dateOfBirthdayTextFied.text = formatter.string(from: birthdayDatePicker.date)
    }
    
    //MARK: - Work with lived days
    
    func dateInterval(beginDate: String, endDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        guard let begin = dateFormatter.date(from: beginDate) else { return "" }
        guard let end = dateFormatter.date(from: endDate) else { return "" }
        
        let dateInteval = Calendar.current.dateComponents([.day], from: begin, to: end)
        
        guard let days = dateInteval.day else { return "" }
        
        let countOfDays = "\(days)"
        return countOfDays
    }
    
    func getCurrentDay() -> String {
        let currentday = DateFormatter()
        currentday.dateFormat = "dd.MM.yyyy"
        
        return currentday.string(from: Date())
    }
    
    func dateIntervaForMen(currentAge: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        guard let currentAgeOfMen = dateFormatter.date(from: currentAge) else { return ""}
        guard let mensLife = Calendar.current.date(byAdding: .year, value: -70, to: Date()) else { return ""}
        
        let dateInterval = Calendar.current.dateComponents([.day], from: mensLife, to: currentAgeOfMen)
        
        guard let days = dateInterval.day else { return ""}
        
        let countOfDays = "\(days)"
        
        return countOfDays
    }
    
    func dateIntervaForWomen(currentAge: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        guard let currentAgeOfWomen = dateFormatter.date(from: currentAge) else { return ""}
        guard let womensLife = Calendar.current.date(byAdding: .year, value: -79, to: Date()) else { return ""}
        
        let dateInterval = Calendar.current.dateComponents([.day], from: womensLife, to: currentAgeOfWomen)
        
        guard let days = dateInterval.day else { return ""}
        
        let countOfDays = "\(days)"
        
        return countOfDays
    }

}
