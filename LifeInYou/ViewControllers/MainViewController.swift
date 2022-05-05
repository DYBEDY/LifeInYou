//
//  MainViewController.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import UIKit


class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var calendarCollectionView: UICollectionView!
    
    @IBOutlet var monthLabel: UILabel!
    
    var selectedDate = Date()
    var totalSquares = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        
        setCellsView()
        setMonthView()
    }
    
  
    @IBAction func previousMonthTapped() {
        selectedDate = CalendarModel().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    
    
    @IBAction func nextMonthTapped() {
        selectedDate = CalendarModel().plusMonth(date: selectedDate)
        setMonthView()
    }
    
  
    
    func setCellsView() {
        let width = (calendarCollectionView.frame.size.width - 2) / 8
        let height = (calendarCollectionView.frame.size.height - 2) / 8
        
        let flowLayout = calendarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarModel().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarModel().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarModel().weekDay(date: firstDayOfMonth )
        
        var count = 1
        
        while count <= 42 {
           
            if count <= startingSpaces || count - startingSpaces > daysInMonth {
                totalSquares.append("")
                
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
           
            count += 1
        }
        
//        let days = totalSquares.filter { $0 != "+" }
//        print(days)
        
        monthLabel.text = CalendarModel().monthString(date: selectedDate) + " " + CalendarModel().yearString(date: selectedDate)
        calendarCollectionView.reloadData()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        cell.dayOfMonthLabel.text = totalSquares[indexPath.item]
        
        return cell
    }
    
}
