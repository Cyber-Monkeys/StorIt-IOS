//
//  LoginViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 12/24/19.
//  Copyright © 2019 Cyber-Monkeys. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate{

    //variables
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       Auth.auth().addStateDidChangeListener
        { (auth, user) in
            
            if user != nil {
              self.goToMenu()
            }
            
        }
          
        GIDSignIn.sharedInstance()?.presentingViewController = self
        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
          // Do any additional setup after loading the view.
        
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
        
        //add icon to txtEmail
        let emailImage = UIImage(systemName: "envelope.fill")
        addLeftImageTo(txtField: txtEmail, andImage: emailImage!)
        //add icon to txtPassword
        let passImage = UIImage(systemName: "lock.fill")
        addLeftImageTo(txtField: txtPassword, andImage: passImage!)
    }
    
    //hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //hide keyboard when user presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        return(true)
    }
    
    //login
    @IBAction func login(_ sender: Any) {
        
        let email = txtEmail.text!
        let password = txtPassword.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
           print(authResult)
            if let firebaseError = error {
                print(firebaseError.localizedDescription)
                return
            }
            
            print("login success")
            //self?.goToMenu()
        }
        
    }
    //go to main page
    func goToMenu(){
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let clientVC:TabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
        
        //go to new screen in fullscreen
        clientVC.modalPresentationStyle = .fullScreen
        self.present(clientVC, animated: true, completion: nil)
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
    
    //go to popup for forgot password
    @IBAction func didTapForgotPass(_ sender: UIButton) {
        
        let popup = ForgotPasswordPopUpViewController.create()
        let cardPopup = SBCardPopupViewController(contentViewController: popup, completionHandler: uselessFunc)
        cardPopup.show(onViewController: self)
        
    }
    func uselessFunc() {
        
    }
    
}
