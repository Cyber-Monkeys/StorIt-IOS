//
//  EditProfileViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 1/23/20.
//  Copyright © 2020 Cyber-Monkeys. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //variables
    @IBOutlet weak var serverPicker: UIPickerView!
    @IBOutlet weak var profPicImage: UIImageView!
    @IBOutlet weak var editBirthdate: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editUsername: UITextField!
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var txtPlanId: UILabel!
    @IBOutlet weak var txtPlanRenewalDate: UILabel!
    @IBOutlet weak var txtPlanCost: UILabel!
    @IBOutlet weak var txtPlanStorage: UILabel!
    @IBOutlet weak var txtPlanCopies: UILabel!
    @IBOutlet weak var regionsLayout: UIStackView!
    var currentUser:User?
    var plan:Plan?
    var birthdate = ""
    var email = ""
    var username = ""
    var name = ""
    var region = ""
    var planId = 0
    var planRenewalDate = ""
    var planCopies = 0
    var planStorage = 0
    var planCost = 0
    
    var planRegions: Array<String> = Array()
    private var datePicker : UIDatePicker?
    let db = Firestore.firestore()
    var docRef = DocumentReference?.self
    var storageRef = Storage.storage().reference()
    let profilePicPicker = UIImagePickerController()
    let serverNames = ["AP", "EU","ME", "NA", "OC", "SA"]
    
    //server picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //set number of rows in a component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return serverNames.count
    }
    
    //set title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return serverNames[row]
    }
    
    //selected row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(serverNames[row])")
        var regions: Array<String> = (currentUser?.getPlan().getPlanRegions())!
        regions[pickerView.tag] = serverNames[row]
        currentUser?.getPlan().setPlanRegions(planRegions: regions)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 15
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return regionsLayout.frame.width
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel:UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
        }
        pickerLabel?.font.withSize(4)
        pickerLabel?.textAlignment = .center
        pickerLabel?.text = serverNames[row]
        
        return pickerLabel!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profPicImage.layer.cornerRadius = profPicImage.frame.size.height/2
        profilePicPicker.delegate = self

        // Do any additional setup after loading the view.
        //for left bar button
        let backButton = UIBarButtonItem(image: UIImage(named: "back-24"), style: .plain, target: self, action: #selector(goBack))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        //for right bar button
        let saveButton = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveInfo))
        
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.editEmail.delegate = self
        self.editUsername.delegate = self
        self.editName.delegate = self
        
        var dates = planRenewalDate.components(separatedBy: "/")
        var dateComponents = DateComponents()
        dateComponents.year = Int(dates[2])
        dateComponents.month = Int(dates[1])
        dateComponents.day = Int(dates[0])
       
        var calendar = Calendar.current
        let mPlanRenewalDate = calendar.date(from: dateComponents)
        
        plan = Plan(planId: planId, planRegions: planRegions, planRenewalDate: mPlanRenewalDate!)
        
        dates = birthdate.components(separatedBy: "/")
        dateComponents.year = Int(dates[2])
        dateComponents.month = Int(dates[1])
        dateComponents.day = Int(dates[0])
        let mBirthdate = calendar.date(from: dateComponents)
        
        currentUser = User(username: username, email: email, name: name, dateOfBirth: mBirthdate!, region: region , plan: plan!)
        
        //assign strings to text field
        editBirthdate.text = birthdate
        editEmail.text = email
        editUsername.text = username
        editName.text = name
        txtPlanId.text = "Plan \(planId)"
        txtPlanCost.text = "$\(planCost)"
        txtPlanRenewalDate.text = "Renewal Date: \(planRenewalDate)"
        txtPlanStorage.text = "\(planStorage) GB"
        txtPlanCopies.text = "\(planCopies) copies"
        
        print(planRegions[0], planRegions[1])
        var numOfRegion: Int = 0
        //self.regionsLayout.alignment = .center
        for region in planRegions {
            numOfRegion = numOfRegion + 1
            let regionHeaderTxt: UILabel = UILabel.init(frame: CGRect(x: 4,y: 5,width: self.regionsLayout.frame.width,height: 24))
            
            regionHeaderTxt.text = "Region \(numOfRegion)"
            regionHeaderTxt.textAlignment = .left
            regionHeaderTxt.font.withSize(10)
            
            let regionPicker: UIPickerView = UIPickerView()
            regionPicker.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
            regionPicker.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
            regionPicker.delegate = self as UIPickerViewDelegate
            regionPicker.dataSource = self as UIPickerViewDataSource
            
            var value = serverNames.firstIndex(of: planRegions[numOfRegion-1])
            regionPicker.selectRow(value! , inComponent: 0, animated: true)
            regionPicker.tag = numOfRegion - 1
            
            //idk.addSubview(regionPicker)
            self.regionsLayout.addArrangedSubview(regionHeaderTxt)
            self.regionsLayout.addArrangedSubview(regionPicker)
        }
        
        //add datepicker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(EditProfileViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        //remove datepicker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        editBirthdate.inputView = datePicker
        
        //download prof pic
        setupProfPic()
    }
    
    //Go back to Menu
    @objc func goBack(){
         dismiss(animated: true, completion: nil)
    }
    
    //save inputs to firestore
    @objc func saveInfo(){
        print("i have pressed save")
        let birthDate = datePicker?.date
        let username = editUsername?.text
        let name = editName?.text
        let email = editEmail?.text
        let firebaseAuth = Auth.auth()
        var userId = firebaseAuth.currentUser!.uid
        
        var planData: [String : Any] = [
            "planId" : currentUser!.getPlan().getPlanId(),
            "planStorage" : currentUser!.getPlan().getPlanStorage(),
            "planCopies" : currentUser!.getPlan().getPlanCopies(),
            "planRegions" : currentUser!.getPlan().getPlanRegions(),
            "planRenewalDate" : currentUser!.getPlan().getRenewalDate()
        ]
        
        self.db.collection("Users").document(userId).updateData([
            "Name": name,
            "Username": username,
            "Email":email,
            "Birthdate": birthDate,
            "Region": currentUser!.getRegion(),
            "plan" : planData
        ]) { err in
            if let err = err {
                print("Error updating document \(err)")
            } else{
                print("Document successfully updated")
            }
        }
        
        //location of storage reference
        let storedImage = storageRef.child("profileImages").child("\(userId).jpeg")
        
        //storing imageurl to firebase user
        if let uploadData = profPicImage.image?.jpegData(compressionQuality: 0.5) {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in

                if error != nil {
                    print(error!)
                    return
                }

                storedImage.downloadURL(completion: { (url, error) in

                    if error != nil {
                        print(error)
                        return
                    }

                    let request = Auth.auth().currentUser?.createProfileChangeRequest()
                    request?.photoURL = url
                    request?.commitChanges { (error) in

                        if error != nil {
                            print("Something is wrong")
                        }

                    }

                })

            })
        }
        
        //add delay before it closes
        //3 secs delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4){
            //then go to profile page
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let profileNC:ProfileNavigationController = storyboard.instantiateViewController(withIdentifier: "ProfileNC") as! ProfileNavigationController
            
            //go to new screen in fullscreen
            profileNC.modalPresentationStyle = .fullScreen
            self.present(profileNC, animated: true, completion: nil)
        }
        
    }
    
    //change profile photo
    @IBAction func didTapChangePhoto(_ sender: Any) {
        
        profilePicPicker.delegate = self 
        profilePicPicker.allowsEditing = true
        profilePicPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(profilePicPicker, animated: true, completion: nil)
    }
    
    //for choosing photo in photo library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profPicImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //for cancelling photo in photo library
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
                            self.profPicImage.image = image
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
    
    //hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //hide keyboard when user presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editEmail.resignFirstResponder()
        editUsername.resignFirstResponder()
        editName.resignFirstResponder()
        return(true)
    }
    
    //hide keyboard
    @objc func viewTapped(gestureRecognizer : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //change date to calendar
    @objc func dateChanged(datePicker : UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        editBirthdate.text = dateFormatter.string(from: datePicker.date)
        
        //removes date picker once user chooses a date
        view.endEditing(true)
        
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

//for navigation controller
class EditProfileNavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
