//
//  ViewController.swift
//  wholeProject
//
//  Created by phoebeezzat on 6/12/19.
//  Copyright © 2019 phoebe. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Alamofire
import Contacts
import EventKit
import UIAlertDateTimePicker
class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate {
   
    
let locationManager = CLLocationManager()
    var filterdItemsArray = [CONTACTS]()
    var smstext : String = ""
    let eventStore : EKEventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var remindstoto = [EKReminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        loadReminder()
        //removeReminder(title: "feby")
       
       //when select weather only
        /*
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()*/
       
    }
    // **********************to take photo and save photos ****************************
    func takePhotos (){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage]as? UIImage{
            picker.dismiss(animated: true, completion: nil)
            UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
            let alert = UIAlertController(title: "saved", message: "yourimage has been saved", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert,animated: true , completion: nil)
        }
    }
//***************************    open photos   **************************************
    func openPhotos (){
        let url : NSURL = URL(string: "photos-redirect://")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
 //**************************  GoogleSearch    *************************************
    func googleSearch(searchSent : String){
       print(searchSent.replacingOccurrences(of: " ", with: "+"))
        let myURLString =  "http://www.google.com/search?hl=ar&q=\(searchSent.replacingOccurrences(of: " ", with: "+"))"
        let url = myURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let myURL = URL(string: url!)
        UIApplication.shared.open(myURL! , options: [:], completionHandler: nil)
    }
//***************************   getWeather    *****************************************
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //last value in array will be more accurate
        let App_id = "1aceb2f3462bcbb96bb892abc52ab2cb"
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print("long = \(location.coordinate.longitude), lat = \(location.coordinate.latitude) ")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String ] = [ "lat" : latitude , "lon" : longitude , "appid" : App_id ]
            getWeather( params: params)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("yess i fail")
        //hn7ot alert
       
    }
    func getWeather(params : [String : String]){
        let weatherURl = "http://api.openweathermap.org/data/2.5/weather"
        Alamofire.request(weatherURl,method: .get ,parameters: params).responseJSON {
            response in
            if response.result.isSuccess{
                print("success,got weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.UpdateWeatherData(json: weatherJSON)
                
            }else{
                // alert connection issues
                let alert = UIAlertController(title: "connection loss", message: "there is an issue in your connection", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                print("error,\(response.result.error ?? 0 as! Error)")
            }
        }
    }
    func UpdateWeatherData(json : JSON){
        let weatherModel = WeatherDataModel()
        if let temp = json["main"]["temp"].double{
            weatherModel.temp = Int(temp - 273.15)
            weatherModel.city = json["name"].stringValue
            weatherModel.condition = json["weather"][0]["id"].intValue
            weatherModel.weatherIcon = weatherModel.updateWeatherIcon(condition: weatherModel.condition)
            let alert = UIAlertController(title : "the Weather",message : "today , the weather is \(weatherModel.temp) in  \(weatherModel.city)",preferredStyle: .alert)
            
            alert.addImage(image: UIImage(named: weatherModel.weatherIcon)!)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            //alert city.text =  locationUNavailable
            let alert = UIAlertController(title: "Location unavailable", message: "can't reach to your location", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //*******************************    call contact     *************************************
    /**/func callContact (cont : String){
        print("ys")
        filterdItemsArray = fetchcontacts().filter { item in
            return item.fullname.lowercased().contains(cont.lowercased())
        }
        print(filterdItemsArray.count)
        if filterdItemsArray.count == 1{
            filterdItemsArray[0].number = filterdItemsArray[0].number.replacingOccurrences(of: " ", with: "")
            let url : NSURL = URL(string: "tel://\(filterdItemsArray[0].number)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }else if filterdItemsArray.count > 1 {
            performSegue(withIdentifier: "callSegue", sender: self)}
        else {
            createcontactAlert(title: "not found ", message: "no matched name of contact found")
        }
    }
    func createcontactAlert (title : String , message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func fetchcontacts() -> [CONTACTS]{
        var fetcontacts = [CONTACTS]()
        let ContactStore = CNContactStore()
        let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
        let fetchreq = CNContactFetchRequest.init(keysToFetch: keys as [CNKeyDescriptor] )
        do{
            try ContactStore.enumerateContacts(with: fetchreq) { (contact, end) in
                let datacontant = CONTACTS(NAME: "\(contact.givenName) \(contact.familyName)", phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "400")
                fetcontacts.append(datacontant)
                //    let dict = [ datacontant.fullname: datacontant.number]
                //    self.contactdic.append(dict)
                print(contact.givenName)
                print(contact.phoneNumbers.first?.value.stringValue ?? "")
            }}
        catch{
            print("failed to fetch")
        }
        return fetcontacts
    }
    //********************************  sendSMS    *******************************
    func sendSMS (cont : String , body : String){
        filterdItemsArray = fetchcontacts().filter { item in
            return item.fullname.lowercased().contains(cont.lowercased())
        }
        print(filterdItemsArray.count)
        guard let escapedBody = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        smstext = escapedBody
        if filterdItemsArray.count == 1{
            filterdItemsArray[0].number = filterdItemsArray[0].number.replacingOccurrences(of: " ", with: "")
            
            let url : NSURL = URL(string: "sms://\(filterdItemsArray[0].number)&body=\(escapedBody)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }else if filterdItemsArray.count > 1 {
            performSegue(withIdentifier: "smsSegue", sender: self)}
        else {
            createcontactAlert(title: "not found ", message: "no matched name of contact found")
        }
    }
    //*******************************    AddReminder       **************************************
   func addReminder (title : String){
   
        let datePicker = UIDatePicker()
    datePicker.datePickerMode = .dateAndTime
    let alert = UIAlertController(title: "Add date", message: nil, preferredStyle: .actionSheet)
    alert.view.addSubview(datePicker)
    let DateTime = datePicker.date
    let ok = UIAlertAction(title: "ok", style: .default) { (action) in
        DispatchQueue.main.async{
        self.eventStore.requestAccess(to: EKEntityType.reminder) { (granted, error) in
             if (granted) && (error == nil) {
                let reminder:EKReminder = EKReminder(eventStore: self.eventStore)
                reminder.title = title
                reminder.priority = 2
                reminder.notes = "...this is a note"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                
                let alarm = EKAlarm(absoluteDate: DateTime)
                reminder.addAlarm(alarm)
                
                reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
                do {
                    try self.eventStore.save(reminder, commit: true)
                    
                } catch {
                    let alert = UIAlertController(title: "Reminder could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        }}
    alert.addAction(ok)
    let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)
    alert.addAction(cancel)
    let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 300)
    alert.view.addConstraint(height)
    self.present(alert, animated: true, completion: nil)
   
    }
    //********************************  remove Reminder **************************************
    func removeReminder (title : String){
        
        var count : Int = 0
        calendars = eventStore.calendars(for: EKEntityType.reminder)
        print("\(calendars?.count)")
         let predict = eventStore.predicateForReminders(in: calendars)
       
            self.eventStore.fetchReminders(matching: predict) { (reminders) in
            for remind in reminders! {
                if remind.title.lowercased().contains(title.lowercased()){
                    do{
                        // remind.isCompleted = true
                        try self.eventStore.remove(remind, commit: true)
                        DispatchQueue.main.async{
                        let alert = UIAlertController(title: "Reminder is successfully removed", message: "", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                            count = count + 1 }
                    }catch{
                       
                    }
                    
                }
            }
            if count == 0 {
                DispatchQueue.main.async{
                let alert = UIAlertController(title: "No remider with this title", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                    self.present(alert, animated: true, completion: nil)}
            }
            }
    }
    //*******************************   load Reminders ********************************/
    func loadReminder(){
        prepareToLoadReminders()
        performSegue(withIdentifier: "ReminderSegue", sender: self)
    }
    func prepareToLoadReminders(){
        print("yes")
        calendars = eventStore.calendars(for: EKEntityType.reminder)
        let predict = eventStore.predicateForReminders(in: calendars)
        eventStore.fetchReminders(matching: predict) { (reminders) in
            self .remindstoto = reminders!
        }}
    //******************************** prepare for all segues **********************************
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! oneTableViewController
        destination.contArray = filterdItemsArray
        if segue.identifier == "callSegue"{
            print("yes")
            destination.Seguesty = segue.identifier!}
        else if segue.identifier == "smsSegue" {
            destination.Seguesty = segue.identifier!
            destination.smstext2 = smstext
        } else if segue.identifier == "ReminderSegue" {
            destination.Seguesty = segue.identifier!
            destination.remindstoto = remindstoto
        }
    }
    }
