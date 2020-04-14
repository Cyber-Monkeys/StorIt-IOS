//
//  File.swift
//  StorIt-IOS
//
//  Created by Amad Khan on 13/03/2020.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import Foundation


class File {
    private var fileId:Int = 0
    private var fileSize:Int = 0
    private var fileName:String = ""
    private var fileType:String = ""
    private var children:Array<File> = []
    private var fileImageName:String = "background_2"
    
    init(fileId:Int, fileSize:Int, fileName:String, fileType:String, isFolder:Bool) {
        self.fileId = fileId
        self.fileSize = fileSize
        self.fileName = fileName
        self.fileType = fileType
        if(!isFolder) {
            fileImageName = "background_2"
        } else {
            fileImageName = "background_3"
        }
    }
    init() {
        
    }
    
    func getFileId() -> Int { return fileId }
    
    func getFileSize() -> Int { return fileSize }
    
    func getFileName() -> String { return fileName }
    
    func getFileType() -> String { return fileType }
    
    func getFileImageName() -> String { return fileImageName }
    
    func setFileId(fileId:Int) { self.fileId = fileId }
    
    func setFileSize(fileSize:Int) { self.fileSize = fileSize }
    
    func setFileName(fileName:String) { self.fileName = fileName }
    
    func setFileType(fileType:String) { self.fileType = fileType }
    
    func setFileImageName(fileImageName:String) { self.fileImageName = fileImageName }
    
}
