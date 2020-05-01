//
//  PlansViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 1/15/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit
import Firebase

class PlansViewController: UIViewController {

    //variables
    @IBOutlet weak var planOne: UIView!
    @IBOutlet weak var planTwo: UIView!
    @IBOutlet weak var planThree: UIView!
    let db = Firestore.firestore()
    var planId: Int = 0
    var planIdToSend:Int = 0
    var isPurchased: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for left bar button
        let backButton = UIBarButtonItem(image: UIImage(named: "back-24"), style: .plain, target: self, action: #selector(goBack))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        //border designs
        planOne.layer.borderColor = UIColor.lightGray.cgColor
        planOne.layer.borderWidth = 0.5
        planOne.layer.cornerRadius = 5
        planTwo.layer.borderColor = UIColor.lightGray.cgColor
        planTwo.layer.borderWidth = 0.5
        planTwo.layer.cornerRadius = 5
        planThree.layer.borderColor = UIColor.lightGray.cgColor
        planThree.layer.borderWidth = 0.5
        planThree.layer.cornerRadius = 5
       
        //onclick for plan
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPurchasePlan))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToPurchasePlan))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(goToPurchasePlan))
        planOne.addGestureRecognizer(tapGesture)
        planTwo.addGestureRecognizer(tapGesture2)
        planThree.addGestureRecognizer(tapGesture3)
        
        var userId = Auth.auth().currentUser!.uid
        
        db.collection("Users").document(userId).getDocument {
            (document, error) in
            if let document = document , document.exists {
                var planData: [String : Any] = document.get("plan") as! [String : Any]
                self.planId = Int(planData["planId"] as! NSNumber)
                switch(self.planId){
                   case 1:
                    self.planOne.layer.backgroundColor = UIColor.green.cgColor
                   case 2:
                    self.planTwo.layer.backgroundColor = UIColor.green.cgColor
                   case 3:
                    self.planThree.layer.backgroundColor = UIColor.green.cgColor
                   default:
                       print("Nothing")
                       self.isPurchased = false
                   }
            } else {
                print("Document doesn't exist")
            }
        }
        
       
        
    }
    
    //Go back
    @objc func goBack(){
         //then go to profile page
          let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
          let tabBarVC:TabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
          
          //go to new screen in fullscreen
         tabBarVC.modalPresentationStyle = .fullScreen
          self.present(tabBarVC, animated: true, completion: nil)
    }
    
    //go to purchase plan
    @objc func goToPurchasePlan(sender : UITapGestureRecognizer){
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let purchasePlanNC:PurchasePlanNavigationController = storyboard.instantiateViewController(withIdentifier: "PurchasePlanNC") as! PurchasePlanNavigationController
        
        let destPurchasePlan = purchasePlanNC.viewControllers.first as? PurchasePlanViewController
        
        switch(sender.view!.tag){
        case 1:
            self.planIdToSend = 1
        case 2:
            self.planIdToSend = 2
        case 3:
            self.planIdToSend = 3
        default:
            self.planIdToSend = 0
        }
        
        if (self.planId == sender.view!.tag){
            self.isPurchased = true
        } else {
            self.isPurchased = false
        }
        
        destPurchasePlan?.planId = planIdToSend
        destPurchasePlan?.isPurchased = isPurchased
        
        //go to new screen in fullscreen
        purchasePlanNC.modalPresentationStyle = .fullScreen
        self.present(purchasePlanNC, animated: true, completion: nil)
        
    }
    
}

//for navigation controller
class PlansNavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
