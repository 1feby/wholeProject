//
//  detailViewController.swift
//  
//
//  Created by phoebeezzat on 6/19/19.
//

import UIKit
import CoreData

class detailViewController: UIViewController{
    var indexOfSelected : Int = 0
    var notes = [Note]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var titlee: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
        titlee.text = notes[indexOfSelected].title
        contentText.text = notes[indexOfSelected].content
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        notes[indexOfSelected].title = titlee.text
        notes[indexOfSelected].content = contentText.text
        saveItem()
    }
    func loadNotes(){
        let request : NSFetchRequest<Note> = Note.fetchRequest()
        do{
            notes = try context.fetch(request)
        }catch {
            print("Error fetching")
        }
        for note in notes {
            print(note.title)
        }
        //
    }
    //*********************  func related to coreData ********************************
    func saveItem(){
        do{
            try context.save()
            
        } catch {
            print("error saving context \(error)")
        }
        
       
        
        
    }
}
