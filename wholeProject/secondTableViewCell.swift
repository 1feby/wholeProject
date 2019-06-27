//
//  secondTableViewCell.swift
//  wholeProject
//
//  Created by phoebeezzat on 6/18/19.
//  Copyright © 2019 phoebe. All rights reserved.
//
import UIKit

class secondTableViewCell: UITableViewCell{
    var parentViewController: UIViewController?
    
    @IBOutlet weak var contentText: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
