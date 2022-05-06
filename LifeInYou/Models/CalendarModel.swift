//
//  CalendarModel.swift
//  LifeInYou
//
//  Created by Roman on 05.05.2022.
//

import UIKit


class CalendarModel {
    
    var calendar = Calendar.current
    
    
    func plusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    func monthString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    func yearString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    
    func daysInMonth(date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func daysInPreviousMonth(date: Date) -> Int {
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: date)!
        
        let range = calendar.range(of: .day, in: .month, for: previousMonth)!
        return range.count
    }

    func daysInFutureMonth(date: Date) -> Int {
        let futureMonth = calendar.date(byAdding: .month, value: 1, to: date)!
        
        let range = calendar.range(of: .day, in: .month, for: futureMonth)!
        return range.count
    }

    
    
    
    func dayOfMonth(date: Date) -> Int {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    func firstOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        
        return calendar.date(from: components)! - 1
    }
    
    func weekDay(date: Date) -> Int {
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday! - 1
    }
    
}
