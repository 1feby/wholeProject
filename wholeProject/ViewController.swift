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
class ViewController: UIViewController,CLLocationManagerDelegate {
let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
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
    
    }
