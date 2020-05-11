//
//  Node.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 4/26/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

//just made it class bc there is no abstract in swift
//protocols exist but not sure if u can use it for polymorphism
class Node: NSObject {
    
    var nodeName: String!
    var isFolder: Bool!
    
    override init(){
        self.nodeName = " "
        self.isFolder = false
    }
    
    init(nodeName: String, isFolder: Bool){
        self.nodeName = nodeName
        self.isFolder = isFolder
    }
    
    func getNodeName() -> String {
        return nodeName
    }
    
    func getIsFolder() -> Bool {
        return isFolder
    }
    
    func setNodeName(nodeName: String){
        self.nodeName = nodeName
    }
    
    //alternative getter
    //    var getNodeName: String! {
    //        get { return nodeName }
    //    }
    //
    //    var getIsFolder: Bool! {
    //        get { return isFolder }
    //    }
    

}
