//
//  File.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 4/27/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class File: Node {
    
    var fileId: Int
    var fileSize: Int
    var fileType: String
    var fileKey: String
    var chunkList: Array<Chunk>
    
    init(fileId: Int, nodeName: String, fileSize: Int, fileType: String, fileKey:String){
        self.fileId = fileId
        self.fileSize = fileSize
        self.fileType = fileType
        self.fileKey = fileKey
        chunkList = Array()
        super.init()
        self.isFolder = false
        self.nodeName = nodeName
    }
    
    func getFileId() -> Int {
        return fileId
    }
    
    func getFileSize() -> Int {
        return fileSize
    }
  
    func getFileType() -> String{
        return fileType
    }
    
    func getFileKey() -> String{
        return fileKey
    }
    
    func setFileId(fileId: Int){
        self.fileId = fileId
    }

    func setFileSize(fileSize: Int){
        self.fileSize = fileSize
    }
    
    func setFileType(fileType: String){
        self.fileType = fileType
    }
    
    func setFileKey(fileKey: String){
        self.fileKey = fileKey
    }
}
