//
//  SignUpViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 12/24/19.
//  Copyright © 2019 Cyber-Monkeys. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mDatePicker: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    var region:String = "EU"
    let regionNames = ["AP","EU","ME","NA","OC", "SA"]
    
    private var datePicker : UIDatePicker?
    let db = Firestore.firestore()
    var docRef = DocumentReference?.self
    
    //region picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //set number of rows in a component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regionNames.count
    }
    
    //set title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regionNames[row]
    }
    
    //selected row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(regionNames[row])")
        region = regionNames[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mTitle.text = "Join the \nCommunity"
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(SignUpViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        //remove datepicker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        mDatePicker.inputView = datePicker
        
        //auth state listener
        Auth.auth().addStateDidChangeListener
        { (auth, user) in
            
            if user != nil {
              self.goToMenu()
            }
            
        }
        
        //add icon to txtEmail
        let emailImage = UIImage(systemName: "envelope.fill")
        addLeftImageTo(txtField: txtEmail, andImage: emailImage!)
        //add icon to txtPassword
        let passImage = UIImage(systemName: "lock.fill")
        addLeftImageTo(txtField: txtPassword, andImage: passImage!)
        addLeftImageTo(txtField: txtConfirmPassword, andImage: passImage!)
        //add icon to txtUsername, firstName, and lastName
        let personImage = UIImage(systemName: "person.fill")
        addLeftImageTo(txtField: txtUsername, andImage: personImage!)
        addLeftImageTo(txtField: txtFirstName, andImage: personImage!)
        addLeftImageTo(txtField: txtLastName, andImage: personImage!)
        //add icon to mDatePicker
        let bDayImage = UIImage(systemName: "calendar")
        addLeftImageTo(txtField: mDatePicker, andImage: bDayImage!)
        
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    //hide keyboard
    @objc func viewTapped(gestureRecognizer : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    //convert date format
    @objc func dateChanged(datePicker : UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        mDatePicker.text = dateFormatter.string(from: datePicker.date)
        
        //removes date picker once user chooses a date
        view.endEditing(true)
        
    }
    
    //sign in user
    @IBAction func signin(_ sender: Any) {
        let email = txtEmail.text!
        let password = txtPassword.text!
        let confirmPassword = txtConfirmPassword.text!
        let username = txtUsername.text!
        let firstName = txtFirstName.text!
        let lastName = txtLastName.text!
        let birthDate = datePicker?.date
        
        let currentUser:User = User(username: username, email: email, name: firstName + " " + lastName, dateOfBirth: birthDate!, region: region)
        let userPlan:Plan = Plan(planId: 1)
        currentUser.setPlan(plan: userPlan)
        
        //check if password is same
        if password == confirmPassword {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
              
                if let firebaseError = error {
                    print(firebaseError.localizedDescription)
                    return
                }
                
                //if success, logout and go to login
                let firebaseAuth = Auth.auth()
                
                let userId = firebaseAuth.currentUser!.uid
                
                var planData: [String : Any] = [
                    "planId" : currentUser.getUsername(),
                    "planStorage" : currentUser.getPlan().getPlanId(),
                    "planCopies" : currentUser.getPlan().getPlanCopies(),
                    "planRegions" : currentUser.getPlan().getPlanRegions(),
                    "planRenewalDate" : currentUser.getPlan().getRenewalDate()
                ]
                
                let user: [String : Any] = [
                    "Username" : currentUser.getUsername(),
                    "Name" : currentUser.getName(),
                    "Email" : currentUser.getEmail(),
                    "Birthdate" : currentUser.getDateOfBirth(),
                    "Region" : currentUser.getRegion(),
                    "plan" : planData
                ]
                self.db.collection("Users").document(userId).setData(user)
                { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    }else{
                        print("Document successfully written!  \(currentUser.getPlan().getPlanStorage()) hjhjh")
                    }
                }
               
            }
        }else{
            print("SOMETHING IS WRONG")
        }
        
    }
    
    //put icon on left side of textfield
    func addLeftImageTo(txtField : UITextField, andImage img: UIImage){
        
        //create outerview to have padding for leftImageView
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: img.size.width+10, height: img.size.height))
        let leftImageView = UIImageView(frame: CGRect(x: 10, y: 0.0, width: img.size.width, height: img.size.height))
        leftImageView.image = img
        outerView.addSubview(leftImageView)
        txtField.leftView = outerView
        txtField.leftView?.tintColor = UIColor.systemGray4
        txtField.leftViewMode = .always
    }
    
    deinit{
        //stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //move textfield when keyboard opens
    @objc func keyboardWillChange(notification: Notification){
        print("Keyboard will show")
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        //move view if textfield is pressed
        if txtConfirmPassword.isEditing || txtPassword.isEditing{
            if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
                
                view.frame.origin.y = -keyboardRect.height
            }else {
                view.frame.origin.y = 0
            }
        }
        
    }
    
    //go to menu
    func goToMenu(){
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let clientVC:TabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
        
        //go to new screen in fullscreen
        clientVC.modalPresentationStyle = .fullScreen
        self.present(clientVC, animated: true, completion: nil)
    }

}
