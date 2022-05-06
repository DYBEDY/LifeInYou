//
//  HomeViewController.swift
//  LifeInYou
//
//  Created by Roman on 06.05.2022.
//

import UIKit

class HomeViewController: UIViewController {
  
    @IBOutlet var calendarCollectionView: UICollectionView!
    
    @IBOutlet var monthLabel: UILabel!
    
    
    
    @IBOutlet var tableView: UITableView!
    
    
    var selectedDate = Date()
    var totalSquares = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        
        setMonthView()
        
    }
    
    
    @IBAction func nextMonthTapped() {
        selectedDate = CalendarModel().plusMonth(date: selectedDate)
                setMonthView()
    }
    
    
    
    @IBAction func previousMonthTapped() {
        selectedDate = CalendarModel().minusMonth(date: selectedDate)
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
        let daysInthePreviousMonth = CalendarModel().daysInPreviousMonth(date: selectedDate)

        
        var count = 1
        var futureDays = 1
        var pastDays = (daysInthePreviousMonth - startingSpaces) + 1
        
        
        while count <= 42 {
            if count <= startingSpaces {
                totalSquares.append(String(pastDays))
                pastDays += 1
            
            } else if count - startingSpaces > daysInMonth {
                totalSquares.append(String(futureDays))
                futureDays += 1
                
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
        count += 1
            
        }
        
        monthLabel.text = CalendarModel().monthString(date: selectedDate) + " " + CalendarModel().yearString(date: selectedDate)
        calendarCollectionView.reloadData()
}


}



    
    
    

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
   
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        cell.numberOfDay.text = totalSquares[indexPath.item]
        cell.layer.cornerRadius = min(cell.frame.size.height, cell.frame.size.width) / 2.0
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.greenSea.cgColor
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.backgroundColor = UIColor.red
       
    
        
    }
 
}
    
    

    
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calCell") as! CalendarTableViewCell
        
        return cell
    }
    
    
   
    

}
