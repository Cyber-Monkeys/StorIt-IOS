//
//  ProfileViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 1/15/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    //variables
    @IBOutlet weak var regionsLayout: UIStackView!
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var txtBirthdate: UILabel!
    @IBOutlet weak var txtEmail: UILabel!
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtName: UILabel!
    private var datePicker : UIDatePicker?
    @IBOutlet weak var txtPlanStorage: UILabel!
    @IBOutlet weak var txtPlanCopies: UILabel!
    @IBOutlet weak var txtPlanCost: UILabel!
    @IBOutlet weak var txtPlanID: UILabel!
    @IBOutlet weak var txtRenewalDate: UILabel!
    let db = Firestore.firestore()
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicImage.layer.cornerRadius = profilePicImage.frame.size.height/2
        
        //for left bar button
        let backButton = UIBarButtonItem(image: UIImage(named: "back-24"), style: .plain, target: self, action: #selector(goBack))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        //Get data from fireStore
        let firebaseAuth = Auth.auth()
        var userId = firebaseAuth.currentUser!.uid
        db.collection("Users").document(userId).getDocument {
            (document, error) in
            if let document = document , document.exists {
                let username = document.get("Username") as! String
                let email = document.get("Email") as! String
                let name = document.get("Name") as! String
                let firbirthdate = document.get("Birthdate") as! Timestamp
                let birthdate = firbirthdate.dateValue()
                let region = document.get("Region") as! String
                var planData: [String : Any] = document.get("plan") as! [String : Any]
                //var planId: Int = Int((planData["planId"] as! NSString).floatValue)
                var planId: Int = Int(planData["planId"] as! NSNumber)
                
                var planRegions: Array<String> = planData["planRegions"] as! Array<String>
                var firdateInTime: Timestamp = planData["planRenewalDate"] as! Timestamp
                var planRenewalDate: Date = firdateInTime.dateValue()
                
                var plan:Plan = Plan(planId: planId, planRegions: planRegions, planRenewalDate: planRenewalDate)
                self.currentUser = User(username: username, email: email, name: name, dateOfBirth: birthdate, region: region, plan: plan)
                
                //set username and email in nav drawer
                self.txtEmail.text = self.currentUser.getEmail()
                self.txtUsername.text = self.currentUser.getUsername()
                self.txtName.text = self.currentUser.getName()
                
                if birthdate == nil {
                    let date = Date()
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: date)
                    let day = calendar.component(.day, from: date)
                    let month = calendar.component(.month, from: date)
                    let myDate = "\(day)/\(month)/\(year)"
                    self.txtBirthdate.text = myDate
                }else {
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: self.currentUser.dateOfBirth)
                    let day = calendar.component(.day, from: self.currentUser.dateOfBirth)
                    let month = calendar.component(.month, from: self.currentUser.dateOfBirth)
                    let myDate = "\(day)/\(month)/\(year)"
                    self.txtBirthdate.text = myDate
                }
                
                self.txtPlanID.text = "Plan \(self.currentUser.getPlan().getPlanId())"
                self.txtPlanCopies.text = "\(self.currentUser.getPlan().getPlanCopies()) copies"
                self.txtPlanStorage.text = "\(self.currentUser.getPlan().getPlanStorage()) GB"
                
                let calendar = Calendar.current
                let year = calendar.component(.year, from: self.currentUser.getPlan().getRenewalDate())
                let day = calendar.component(.day, from: self.currentUser.getPlan().getRenewalDate())
                let month = calendar.component(.month, from: self.currentUser.getPlan().getRenewalDate())
                let renewalDate = "\(day)/\(month)/\(year)"
                self.txtRenewalDate.text = "Renewal Date: " + renewalDate
                self.txtPlanCost.text = "$ \(self.currentUser.getPlan().getPlanCost())"
                
                var numOfRegion: Int = 0
                for region in planRegions {
                    numOfRegion = numOfRegion + 1
                    let regionHeaderTxt: UILabel = UILabel.init(frame: CGRect(x: 4,y: 5,width: self.regionsLayout.frame.width,height: 24))
                    
                    regionHeaderTxt.text = "Region \(numOfRegion)"
                    regionHeaderTxt.textAlignment = .left
                    regionHeaderTxt.font.withSize(10)
                    
                    let regionTxt: UILabel = UILabel.init(frame: CGRect(x: 4,y: 5,width: self.regionsLayout.frame.width,height: 24))
                    
                    regionTxt.text = region
                    regionTxt.textAlignment = .left
                    regionTxt.font.withSize(10)
                    self.regionsLayout.addArrangedSubview(regionHeaderTxt)
                    self.regionsLayout.addArrangedSubview(regionTxt)
                }
                
                
            } else {
                print("Document doesn't exist")
            }
        }
        
        //download prof pic
        setupProfPic()
       
    }

    //Go back to Menu
    @objc func goBack(){
         //then go to profile page
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarVC:TabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
          
          //go to new screen in fullscreen
        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: true, completion: nil)
    }
    
    //go to editprofile
    //send data to edit profile
    //using override func prepare
    @IBAction func goToEditProfile(_ sender: Any) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
    
    //download prof image from firebase storage
    func setupProfPic(){
        let firebaseAuth = Auth.auth()
        var user = firebaseAuth.currentUser
        
        let url : URL? = user?.photoURL
        
        if url != nil{
            downloadPickTask(url: url!)
        }
        
    }
    
    //download url image and set to imageView
    private func downloadPickTask(url: URL){
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: url) { (data,response, error) in
            
            if let e = error {
                print("Error downloading")
            } else {
                if let res = response as? HTTPURLResponse {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        
                        DispatchQueue.main.async {
                            self.profilePicImage.image = image
                        }
                        
                    }
                    else{
                        print("Couldn't get image")
                    }
                } else {
                    print("Could not get response")
                }
            }
            
        }
        downloadPicTask.resume()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Have to connect to nav controller first then view controller
        let dest = segue.destination as? EditProfileNavigationController
        let destEditProf = dest?.viewControllers.first as? EditProfileViewController
        
        //send attribute to edit profile
        destEditProf?.name = currentUser.getName()
        destEditProf?.username = currentUser.getUsername()
        destEditProf?.email = currentUser.getEmail()
        destEditProf?.birthdate = txtBirthdate!.text!
        destEditProf?.region = currentUser.getRegion()
        destEditProf?.planId = currentUser.getPlan().getPlanId()
        destEditProf?.planRegions = currentUser.getPlan().getPlanRegions()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self.currentUser.getPlan().getRenewalDate())
        let day = calendar.component(.day, from: self.currentUser.getPlan().getRenewalDate())
        let month = calendar.component(.month, from: self.currentUser.getPlan().getRenewalDate())
        let renewalDate = "\(day)/\(month)/\(year)"
        destEditProf?.planRenewalDate = renewalDate
        destEditProf?.planCopies = currentUser.getPlan().getPlanCopies()
        destEditProf?.planStorage = currentUser.getPlan().getPlanStorage()
        destEditProf?.planCost = currentUser.getPlan().planCost
        
    }
    

}

//for navigation controller
class ProfileNavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
