//
//  RoomCell.swift
//  mychess
//
//  Created by 陶侃 on 5/8/16.
//  Copyright © 2016 taokan. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell{
    
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var playerTwo: UILabel!
    @IBOutlet weak var playerOne: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(red: 55/255, green: 186/255, blue: 89/255, alpha: 0.5)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
