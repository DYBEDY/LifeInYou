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
    
    @IBOutlet var daysStackView: UIStackView!
    
    let sectionInserts = UIEdgeInsets(top: 10, left: 3, bottom: 10, right: 3)
    
    var selectedDate = Date()
    var totalSquares = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
//        setCellsView()
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

monthLabel.text = CalendarModel().monthString(date: selectedDate) + " " + CalendarModel().yearString(date: selectedDate)
calendarCollectionView.reloadData()
}

        
//        let daysInMonth = CalendarModel().daysInMonth(date: selectedDate)
//        let firstDayOfMonth = CalendarModel().firstOfMonth(date: selectedDate)
//        let startingSpaces = CalendarModel().weekDay(date: firstDayOfMonth )
//        let daysInthePreviousMonth = CalendarModel().daysInPreviousMonth(date: selectedDate)
//
//
//        var count = 1
//        var futureDays = 1
//        var pastDays = (daysInthePreviousMonth - startingSpaces) + 1
//
//
//        while count <= 42 {
//            if count <= startingSpaces {
//                totalSquares.append(String(pastDays))
//                pastDays += 1
//
//            } else if count - startingSpaces > daysInMonth {
//                totalSquares.append(String(futureDays))
//                futureDays += 1
//
//            } else {
//                totalSquares.append(String(count - startingSpaces))
//            }
//        count += 1
//
//        }
        
//        totalSquares.removeAll()

  


    
    func setupCell(cell: CalendarCollectionViewCell) {
        let currentDay = String(CalendarModel().dayOfMonth(date: selectedDate))
        let currentMonthLabel = CalendarModel().monthString(date: selectedDate) + " " + CalendarModel().yearString(date: selectedDate)
        let currentMonth = CalendarModel().monthString(date: Date()) + " " + CalendarModel().yearString(date: Date())
        
        
        if cell.numberOfDay.text == currentDay && monthLabel.text == currentMonthLabel && currentMonthLabel == currentMonth {
            cell.backgroundColor = .red
        } else {
            cell.backgroundColor = .white
        }
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
        
        setupCell(cell: cell)
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = collectionView.cellForItem(at: indexPath)

    }
 
}
    
    
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 8
        let paddingWidth = 6 * (itemsPerRow)
        let avalibleWidth = ( daysStackView.bounds.width ) - paddingWidth
        let widthPerItem = avalibleWidth / itemsPerRow
        let hightPerItem = widthPerItem

        return CGSize(width: widthPerItem, height: hightPerItem)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInserts
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInserts.left

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
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
