//
//  ServerTableViewCell.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 1/16/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class ServerTableViewCell: UITableViewCell {

    //variable
    @IBOutlet weak var serverName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
