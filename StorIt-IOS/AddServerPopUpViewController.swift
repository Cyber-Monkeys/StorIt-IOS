//
//  AddServerPopUpViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 1/17/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class AddServerPopUpViewController: UIViewController, SBCardPopupContent {
    
    //variables
    var popupViewController: SBCardPopupViewController?
    
    var allowsTapToDismissPopupCard: Bool = true
    
    var allowsSwipeToDismissPopupCard: Bool = true
    
    @IBOutlet weak var sliderStorageValue: UILabel!
    @IBOutlet weak var sliderStorage: UISlider!

    
    //let create initiate for popup
    static func create () -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "AddServer") as! AddServerPopUpViewController
        
        return storyboard
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
<<<<<<< HEAD
    
    @IBAction func cancelServer(_ sender: Any) {
=======
    // add server
    @IBAction func didAddServer(_ sender: Any) {
>>>>>>> master
        self.popupViewController?.close()
    }
    // cancel popup
    @IBAction func didCancelServer(_ sender: Any) {
        self.popupViewController?.close()
    }
    //when slider is moved, change value
    @IBAction func didChangeSlider(_ sender: UISlider) {
        
        sliderStorageValue.text = "\(Int(sender.value.rounded())) MB"
    }
    
    @IBAction func AddServer(_ sender: Any) {
        self.popupViewController?.closeWithCompletion()
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
