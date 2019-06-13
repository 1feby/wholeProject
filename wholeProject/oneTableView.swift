//
//  oneTableView.swift
//  wholeProject
//
//  Created by phoebeezzat on 6/12/19.
//  Copyright © 2019 phoebe. All rights reserved.
//
import UIKit
import Contacts
import EventKit
class oneTableViewController : UITableViewController {
    var contArray = [CONTACTS]()
     var Seguesty : String = ""
    var smstext2 : String = ""
    var remindstoto = [EKReminder]()
    var url: NSURL!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hor")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{
            print("rrf \(contArray.count)")
            return contArray.count
        }else if Seguesty == "ReminderSegue"{
            return remindstoto.count
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "oneCell", for: indexPath) as! TableViewCell
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{
            
            cell.MainLabel.text = contArray[indexPath.row].fullname
            cell.secondLabel.text = contArray[indexPath.row].number
           /* cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true*/
        }else if Seguesty == "ReminderSegue"{
            cell.MainLabel.text = remindstoto[indexPath.row].title
            cell.secondLabel.isHidden = true
        }
        return cell
}
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Seguesty == "callSegue"{
            contArray[indexPath.row].number = contArray[indexPath.row].number.replacingOccurrences(of: " ", with: "")
            url = URL(string: "telprompt://\(contArray[indexPath.row].number)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)}
    else if Seguesty == "smsSegue"{
    contArray[indexPath.row].number = contArray[indexPath.row].number.replacingOccurrences(of: " ", with: "")
   url = URL(string: "sms://\(contArray[indexPath.row].number)&body=\(smstext2)")! as NSURL
    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            print("\(smstext2)")
        }else if Seguesty == "ReminderSegue"{
            url = URL(string:
                "x-apple-reminder://\(remindstoto[indexPath.row].calendarItemIdentifier)")! as NSURL
           // print(remindstoto[indexPath.row].calendarItemIdentifier)
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            
        }
}
}
