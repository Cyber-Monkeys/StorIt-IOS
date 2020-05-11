//
//  fileDetailsPopUpViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 5/10/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit

class fileDetailsPopUpViewController: UIViewController, SBCardPopupContent {
    
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard: Bool = true
    var allowsSwipeToDismissPopupCard: Bool = true
    var fileName: String = ""
    var fileSize: String = ""
    var fileType: String = ""
    @IBOutlet weak var txtFileName: UILabel!
    @IBOutlet weak var txtFileSize: UILabel!
    @IBOutlet weak var txtFileType: UILabel!
    
    
    //let create initiate for popup
    static func create () -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "FileDetails") as! fileDetailsPopUpViewController
        
        return storyboard
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFileName.text = "Name: " + fileName
        txtFileSize.text = "File Size: " + fileSize
        txtFileType.text = "File Type: " + fileType

        // Do any additional setup after loading the view.
    }
    

    @IBAction func tapCancel(_ sender: Any) {
        self.popupViewController?.close()
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
