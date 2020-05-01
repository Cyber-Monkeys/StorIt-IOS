//
//  PurchasePlanViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 2/20/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class PurchasePlanViewController: UIViewController{
    
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var txtPlanId: UILabel!
    @IBOutlet weak var txtPlanCost: UILabel!
    @IBOutlet weak var txtPlanStorage: UILabel!
    @IBOutlet weak var txtPlanCopies: UILabel!
    @IBOutlet weak var txtPlanRegions: UILabel!
    @IBOutlet weak var planThree: UIView!
    var planId:Int = 0
    var isPurchased: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //for left bar button
        let backButton = UIBarButtonItem(image: UIImage(named: "back-24"), style: .plain, target: self, action: #selector(goBack))
        
        self.navigationItem.leftBarButtonItem = backButton
        // Do any additional setup after loading the view.
        
        planThree.layer.cornerRadius = 5

        switch(planId){
        case 1:
            txtPlanId.text = "Plan 1"
            txtPlanCost.text = "$5"
            txtPlanStorage.text = "1 GB"
            txtPlanCopies.text = "2 copies"
            txtPlanRegions.text = "1 Region"
        case 2:
            txtPlanId.text = "Plan 2"
            txtPlanCost.text = "$10"
            txtPlanStorage.text = "5 GB"
            txtPlanCopies.text = "2 copies"
            txtPlanRegions.text = "2 Regions"
        case 3:
            txtPlanId.text = "Plan 3"
            txtPlanCost.text = "$15"
            txtPlanStorage.text = "5 GB"
            txtPlanCopies.text = "3 copies"
            txtPlanRegions.text = "2 Regions"
        default:
            print("nothing")
        }
        
        if(isPurchased == true){
            checkoutButton.isHidden = true
        } else {
            checkoutButton.isHidden = false
        }
        
    }
    
    //Go back
    @objc func goBack(){
         dismiss(animated: true, completion: nil)
    }
    

}

//for navigation controller
class PurchasePlanNavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
