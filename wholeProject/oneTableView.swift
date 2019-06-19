//
//  oneTableView.swift
//  wholeProject
//
//  Created by phoebeezzat on 6/12/19/Users/pavlyremon/Desktop/wholeProject/wholeProject/oneTableView.swift.
//  Copyright © 2019 phoebe. All rights reserved.
//
import UIKit
import Contacts
import EventKit
import MediaPlayer
import CoreData

class oneTableViewController : UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playListTable = [String]()
    var numofSong = [Int]()
    var contArray = [CONTACTS]()
     var Seguesty : String = ""
    var smstext2 : String = ""
    var selectedIndex : Int = 0
    var remindstoto = [EKReminder]()
    var eventTa = [EKEvent]()
    var noteTa = [Note]()
    var url: NSURL!
    let myMediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
     let playlists = MPMediaQuery.playlists().collections
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hor")
        tableView.reloadData()
        loadNotes()
       
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{
            print("rrf \(contArray.count)")
            return contArray.count
        }else if Seguesty == "ReminderSegue"{
            return remindstoto.count
        }else if Seguesty == "eventSegue" {
            print("slsls")
            return eventTa.count
        }else if Seguesty == "musicSegue" {
            return playListTable.count
        }else if Seguesty == "noteSegue" {
            return noteTa.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "oneCell", for: indexPath) as! TableViewCell
        
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{
            
            cell.MainLabel.text = contArray[indexPath.row].fullname
            cell.secondLabel.text = contArray[indexPath.row].number
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
           /* cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true*/
        }else if Seguesty == "ReminderSegue"{
            cell.MainLabel.text = remindstoto[indexPath.row].title
            cell.secondLabel.isHidden = true
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "eventSegue"{
            cell.MainLabel.text = eventTa[indexPath.row].title
            cell.secondLabel.text = "Start date: \(eventTa[indexPath.row].startDate ?? Date())"
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "musicSegue"{
            cell.MainLabel.text = playListTable[indexPath.row]
            cell.secondLabel.text = "\(numofSong[indexPath.row]) songs"
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "noteSegue" {
            cell.MainLabel.text = noteTa[indexPath.row].title
            cell.secondLabel.text = noteTa[indexPath.row].content
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }
        return cell
}
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if  editingStyle == UITableViewCell.EditingStyle.delete  {
            context.delete(noteTa[indexPath.row])
            noteTa.remove(at: indexPath.row)
            saveItem()
            self.tableView.reloadData()
        }
        
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
    
        }else if Seguesty == "eventSegue"{
            gotoAppleCalendar(date: eventTa[indexPath.row].startDate as! NSDate)
        }else if Seguesty == "musicSegue"{
            // Add a playback queue containing all songs on the device
            myMediaPlayer.setQueue(with: playlists![indexPath.row])
            // Start playing from the beginning of the queue
            myMediaPlayer.play()
        }else if Seguesty == "noteSegue" {
            selectedIndex = indexPath.row
            performSegue(withIdentifier: "detailSegue", sender: self)
        }
}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! detailViewController
        destination.indexOfSelected = selectedIndex
    }
    func gotoAppleCalendar(date: NSDate) {
        let interval = date.timeIntervalSinceReferenceDate
        let url = NSURL(string: "calshow:\(interval)")!
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    func loadNotes(){
        let request : NSFetchRequest<Note> = Note.fetchRequest()
        do{
           noteTa = try context.fetch(request)
        }catch {
            print("Error fetching")
        }
        for note in noteTa {
            print(note.title)
        }
        //performSegue(withIdentifier: "noteSegue", sender: self)
    }
    func saveItem(){
        do{
            try context.save()
            
        } catch {
            print("error saving context \(error)")
        }
        
        
    }
}
