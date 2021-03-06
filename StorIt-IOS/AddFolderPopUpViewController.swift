//
//  AddFolderPopUpViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 3/8/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit
import Firebase

class AddFolderPopUpViewController: UIViewController, SBCardPopupContent  {
    
    //variables
    @IBOutlet weak var folderTextField: UITextField!
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard: Bool = true
    var allowsSwipeToDismissPopupCard: Bool = true
    var db : Firestore = Firestore.firestore()
    var firebaseAuth: Auth = Auth.auth()
    var userId : String = ""
    var documentPath: String! = ""
    var fullDirectory: String! = ""
    
    //let create initiate for popup
    static func create () -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "AddFolder") as! AddFolderPopUpViewController
        
        return storyboard
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        firebaseAuth = Auth.auth()
        userId = firebaseAuth.currentUser!.uid
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapCancel(_ sender: Any) {
        self.popupViewController?.close()
    }
    
    @IBAction func tapAdd(_ sender: Any) {
        /*******************************/
        /*BE CAREFUL WITH OPTIONAL*/
        /*IT WILL CAUSE A LOT OF ERROR IN SENDING STUFF IN FIREBASE*/
        /*ESPECIALLY DOCUMENT REFERENCE PATH*/
         /*******************************/
        //for adding dir in new child
        let folderName = String(folderTextField.text!)
        let backSlash = "/"
        let newDocumentPath = documentPath + backSlash + folderName + backSlash + userId
        let dataToSave: [String : Any] = [
            "dir" : ","
        ]
        self.db.document(newDocumentPath).setData(dataToSave)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            }else{
                print("Document successfully written!")
            }
        }
        
        //update dir of current directory of doc reference
        let comma = ","
        let updatedFullDirectory = fullDirectory + comma + folderName
        let fullDirectoryToSave: [String : Any] = [
            "dir" : updatedFullDirectory
        ]
        self.db.document(documentPath!).updateData(fullDirectoryToSave)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            }else{
                print("Document successfully written!")
            }
        }
        
        self.popupViewController?.close()
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let tabBarVC:TabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
         
         //go to new screen in fullscreen
        tabBarVC.modalPresentationStyle = .fullScreen
         self.present(tabBarVC, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
