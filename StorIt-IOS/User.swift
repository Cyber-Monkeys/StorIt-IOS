//
//  User.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 4/27/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class User {
    
    var username: String
    var email: String
    var name: String
    var dateOfBirth: Date
    var region: String
    var plan: Plan?
    var privateKey: String?
    var publicKey: String?
    
    init(username: String, email: String, name: String, dateOfBirth: Date, region: String){
        self.username = username
        self.email = email
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.region = region
    }
    
    init(username: String, email: String, name: String, dateOfBirth: Date, region: String, plan: Plan){
        self.username = username
        self.email = email
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.region = region
        self.plan = plan
    }
    
    init(username: String, email: String, name: String, dateOfBirth: Date, region: String, privateKey: String, publicKey: String){
        self.username = username
        self.email = email
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.region = region
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    init(username: String, email: String, name: String, dateOfBirth: Date, region: String, plan: Plan, privateKey: String, publicKey: String){
        self.username = username
        self.email = email
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.region = region
        self.plan = plan
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    func getUsername() -> String{
        return username
    }
    
    func getEmail() -> String {
        return email
    }
    
    func getName() -> String {
        return name
    }
    
    func getDateOfBirth() -> Date {
        return dateOfBirth
    }
    
    func getRegion() -> String {
        return region
    }
    
    func getPlan() -> Plan {
        return plan!
    }
    
    func getPrivateKey() -> String {
        return privateKey!
    }
    
    func getPublicKey() -> String {
        return publicKey!
    }
    
    func setUsername(username: String){
        self.username = username
    }
    
    func setEmail(email: String){
        self.email = email
    }
    
    func setName(name : String){
        self.name = name
    }
    
    func setDateOfBirth(dateOfBirth: Date){
        self.dateOfBirth = dateOfBirth
    }
    
    func setRegion(region: String){
        self.region = region
    }
    
    func setPlan(plan: Plan){
        self.plan = plan
    }
    
    func setPrivateKey(privateKey: String){
        self.privateKey = privateKey
    }
    
    func setPublicKey(publicKey: String){
        self.publicKey = publicKey
    }

}
