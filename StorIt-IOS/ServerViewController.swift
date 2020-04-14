//
//  ServerViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 12/25/19.
//  Copyright © 2019 Cyber-Monkeys. All rights reserved.
//

import UIKit
import WebRTC
import Firebase

class ServerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //variables
    @IBOutlet weak var fab : UIButton!
    var list:[String] = []
    var server:WebRTCClient?
    
    @IBOutlet weak var receivedImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    //set number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    //initailizer
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         as! ServerTableViewCell
        
        cell.serverName.text = list[indexPath.row]
         
         return cell
        
    }

    //create object of SlideInTransition class
    let transition = SlideInTransition()

    //When left BarButtonItem is pressed
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController  = storyboard?.instantiateViewController(withIdentifier: "MenuTVC")
            else{
                return
        }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self as! UIViewControllerTransitioningDelegate
        present(menuViewController, animated: true)
        
        //Go back to Menu controller
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        transition.dimmingView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil){
        dismiss(animated: true, completion: nil)
    }
    
    //add server popup
    @IBAction func didTapPopup(_ sender: UIButton) {
        let popup = AddServerPopUpViewController.create()
        let cardPopup = SBCardPopupViewController(contentViewController: popup, completionHandler: createServer)
        cardPopup.show(onViewController: self)
    }
    func createServer() {
        Auth.auth().currentUser?.getIDToken(completion: emitServer)
    }
    func emitServer(token:String?, error: Error?) {
        print("token verified")
        let devId = UIDevice.current.identifierForVendor?.uuidString
        print("device id ", devId)
        self.server = WebRTCClient(img:receivedImg, token:token!, storageSize: 500, devId:devId!)
//        self.server?.emitServer(token: token!, storageSize: 500, deviceId: devid!)
        self.list.append("server 1")
        DispatchQueue.main.async {
//            let tableView = self.tableView as UITableViewController
//            self.tableView.
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       //floating action bar
        fab.layer.cornerRadius = fab.frame.height/2
        fab.layer.shadowOpacity = 0.25
        fab.layer.shadowRadius = 5
        fab.layer.shadowOffset = CGSize(width: 0, height: 10)
    }
    
    
    
}

//nav drawer
extension ServerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}
