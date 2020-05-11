//
//  AddFolderPopUpViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 3/8/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit
import Firebase

class AddFolderPopUpViewController: UIViewController, SBCardPopupContent {
    
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
        
        let newFolder: Folder! = Folder(nodeName: String(folderTextField.text!))
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabBarVC:TabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController

        let clientNC = tabBarVC.viewControllers![0] as! ClientNavigationController
        let destClient = clientNC.viewControllers.first as? ClientViewController
        destClient?.addedFolder = newFolder.getNodeName()

        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: true, completion: nil)
        
//        let clientNC:ClientNavigationController = storyboard.instantiateViewController(withIdentifier: "ClientNC") as! ClientNavigationController
//
//        let destClient = clientNC.viewControllers.first as? ClientViewController
//
//        //destClient?.nodeList.append(newFolder)
//        destClient?.addedFolder = newFolder.getNodeName()
//
//        clientNC.modalPresentationStyle = .fullScreen
//        self.present(clientNC, animated: true, completion: nil)
        
        
//        let tabBarVC:TabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
//
//          //go to new screen in fullscreen
//        tabBarVC.modalPresentationStyle = .fullScreen
//        self.present(tabBarVC, animated: true, completion: nil)
        
        self.popupViewController?.close()
    }
    
}
