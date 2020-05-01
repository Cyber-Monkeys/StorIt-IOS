//
//  Chunk.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 4/27/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class Chunk {
    
    private var chunkId: Int!
    private var chunkIv: String!
    
    init(chunkId: Int, chunkIv: String){
        self.chunkId = chunkId
        self.chunkIv = chunkIv
    }
    
    func getChunkId() -> Int {
        return chunkId
    }
    
    func getChunkIv() -> String {
        return chunkIv
    }
    
    func setChunkId(chunkId: Int){
        self.chunkId = chunkId
    }
    
    func setChunkIv(chunkIv: String){
        self.chunkIv = chunkIv
    }

}
