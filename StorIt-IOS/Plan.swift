//
//  Plan.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 4/27/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class Plan {
    
    var planId: Int
    var planStorage: Int
    var planRegions: Array<String>
    var planCopies: Int
    var renewalDate: Date
    var planCost: Int
    
    init(planId: Int){
        self.planId = planId
        planRegions = Array()
        if(planId == 1){
            planStorage = 1000
            planCopies = 2
            planCost = 5
            planRegions.append("EU")
            planRegions.append("NA")
        }else if(planId == 2){
            planStorage = 5000
            planCopies = 2
            planCost = 10
            planRegions.append("EU")
            planRegions.append("NA")
        }else{ //plan 3
            planStorage = 5000
            planCopies = 3
            planCost = 15
            planRegions.append("EU")
            planRegions.append("EU")
            planRegions.append("NA")
        }
        self.renewalDate = Date()
    }
    
    init(planId: Int, planRegions: Array<String>, planRenewalDate: Date){
        self.planId = planId
        if(planId == 1){
            planStorage = 1000
            planCopies = 2
            planCost = 5
        }else if(planId == 2){
            planStorage = 5000
            planCopies = 2
            planCost = 10
        }else{ //plan 3
            planStorage = 5000
            planCopies = 3
            planCost = 15
        }
        self.planRegions = planRegions
        self.renewalDate = planRenewalDate
    }
    
    func getPlanId() -> Int {
        return planId
    }
    
    func getPlanStorage() -> Int {
        return planStorage
    }
    
    func getPlanRegions() -> Array<String> {
        return planRegions
    }
    
    func getPlanCopies() -> Int {
        return planCopies
    }
    
    func getRenewalDate() -> Date {
        return renewalDate
    }
    
    func getPlanCost() -> Int {
        return planCost
    }
    
    func setPlanId(planId: Int){
        self.planId = planId
    }
    
    func setPlanStorage(planStorage: Int){
        self.planStorage = planStorage
    }
    
    func setPlanRegions(planRegions: Array<String>){
        self.planRegions = planRegions
    }
    
    func setPlanCopies(planCopies: Int){
        self.planCopies = planCopies
    }
    
    func setRenewalDate(renewalDate: Date){
        self.renewalDate = renewalDate
    }
    
    func setPlanCost(planCost: Int){
        self.planCost = planCost
    }

}
