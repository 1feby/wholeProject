//
//  ViewController.swift
//  wholeProject
//
//  Created by phoebeezzat on 6/12/19.
//  Copyright © 2019 phoebe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        googleSearch(searchSent: "مسلسلات رمضان")
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
    

    }
