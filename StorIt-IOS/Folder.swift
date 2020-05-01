//
//  Folder.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 4/27/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class Folder: Node{
    
    init(nodeName: String){
        super.init()
        self.nodeName = nodeName
        self.isFolder = true
    }

}
