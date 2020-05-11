//
//  ClientViewController.swift
//  StorIt-IOS
//
//  Created by Fidel Lim on 12/24/19.
//  Copyright © 2019 Cyber-Monkeys. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import MobileCoreServices //import docs

class ClientViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    //variables

    @IBOutlet weak var moveHereButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var goBackButton: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortByTxt: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fab : UIButton!
    let transparentView = UIView()
    let sortByTableView = UITableView() //add new pop up
    let addNewTableView = UITableView()
    let moreOptionsTableView = UITableView()
    var db : Firestore = Firestore.firestore()
    var firebaseAuth: Auth = Auth.auth()
    var userId : String = ""
    var documentPath:String = ""
    var rootPath:String = ""
    var fullDirectory : String = ""
    var userReference : String = ""
    let folderIcon:UIImage = UIImage(named: "folder_transparent2")!
    let fileIcon: UIImage = UIImage(named: "file_transparent2")!
    var positionOfCell : Int = 0
    var isFileMoved: Bool = false
    
    //For sortby popup
    let sortByImage: [UIImage] = [
        UIImage(systemName: "arrow.up")!,
        UIImage(systemName: "arrow.down")!
    ]
    let sortByList = [
        "Name","Name"
    ]
    //For more options popup
    var moreOptionsList = [
        "Folder","Share", "Download", "Move",
        "Duplicate", "Details", "Backup", "Remove"
    ]
    var moreOptionsImage: [UIImage] = [
        UIImage(systemName: "folder")!, UIImage(named: "icons8-shared-document-24")!,
        UIImage(named: "icons8-downloads-24")!, UIImage(named: "icons8-send-file-24")!,
        UIImage(named: "icons8-copy-30")!, UIImage(systemName: "info.circle")!,
        UIImage(named: "icons8-copy-30")!, UIImage(systemName: "trash")!
    ]
    
    var addedFolder:String = " "
    var moveFileDocumentPath: String = " "
    var fileToMove: Node?
    var nodeList: Array<Node> = Array<Node>()
    var tempNodeList: Array<Node> = Array<Node>()
    var fileToMoveNodeList: Array<Node> = Array<Node>()
    var extra: File = File(fileId: 1, nodeName: "Testing", fileSize: 232, fileType: "dsd", fileKey: "fdfd")
    var extra2: Folder = Folder(nodeName: "hello")

    //create object of SlideInTransition class
    let transition = SlideInTransition()
    
    //CollectionView for Client page
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ClientCollectionViewCell
        
        if(nodeList[indexPath.row].getIsFolder()){
            cell.fileType.image = folderIcon
            cell.moreOptions.isHidden = true
        }else{
            cell.fileType.image = fileIcon
        }
        
        if(isFileMoved){
            cell.moreOptions.isHidden = true
        } else {
            cell.moreOptions.isHidden = false
            if(nodeList[indexPath.row].getIsFolder()){
                cell.fileType.image = folderIcon
                cell.moreOptions.isHidden = true
            }
        }
        
        cell.fileName.text = nodeList[indexPath.row].getNodeName()
        cell.moreOptions.tag = indexPath.row
        cell.moreOptions.addTarget(self, action: #selector(ClientViewController.tapMoreOptions(_:)), for: .touchUpInside)
        return cell
    }
    //selecting a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("printed \(nodeList[indexPath.row].getNodeName())")
        if (nodeList[indexPath.row].getIsFolder()){
            documentPath = "\(documentPath)/\(nodeList[indexPath.row].getNodeName())/\(userId)"
            //updateCurrentDirOfDevice(currentDir: documentPath) //update dir to firebase
            loadCurrentDirectory()
        }else {
            //download the file and dislay
        }
    }

    //onlick function of moreOptions
    //popup slide up menu
    @objc func tapMoreOptions(_ sender: UIButton){
        let window = UIApplication.shared.keyWindow //to access nav controller
        
        //get position of button in collection view
        var buttonPosition = sender.convert(CGPoint(), to: collectionView)
        var indexPath = collectionView.indexPathForItem(at: buttonPosition)
        positionOfCell = indexPath!.row //set position of cell
        print("\(positionOfCell) ===== \(nodeList[positionOfCell].getNodeName())")
        moreOptionsList[0] = nodeList[positionOfCell].getNodeName()
        if (nodeList[positionOfCell].getIsFolder()){
            moreOptionsImage[0] = UIImage(named: "folder_transparent2")!
        } else {
            moreOptionsImage[0] = UIImage(named: "file_transparent2")!
        }
        moreOptionsTableView.reloadData() //refresh
        
        //change its color when pressed
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        
        //create tableView
        let screenSize = UIScreen.main.bounds.size
        sortByTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 400)
        window?.addSubview(moreOptionsTableView)
        
        //to go back to original state
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickTransparentViewForMoreOptions))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.moreOptionsTableView.frame = CGRect(x: 0, y: screenSize.height - 400, width: screenSize.width, height: 400)
        }, completion: nil)
    }

    //remove pop of from sortBy
    @objc func clickTransparentViewForMoreOptions(){
        let screenSize = UIScreen.main.bounds.size
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.moreOptionsTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 400)
        }, completion: nil)
    }
    
    //Pressing nav drawer icon
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
    
    //when user press search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    //search bar cancel button pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true) //dismiss keyboard
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Searched text: \(searchText)")
        if (searchText == ""){
            loadCurrentDirectory()
        } else {
            //loadDirectory()
            searchFileFolder(fileFolderName: searchText)
        }
    }
    
    //Display to portrait mode
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    //makes screen orientation for others Viewcontroller according to device physical orientation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        firebaseAuth = Auth.auth()
        userId = firebaseAuth.currentUser!.uid
        print("MY user id : \(userId)")
        documentPath = "/Users/\(userId)/TreeNode/1"
        rootPath = "/Users/\(userId)/TreeNode/1"
        userReference = "/Users/\(userId)"
        
        goBackButton.isHidden = true //hide the view
        moveHereButton.isHidden = true
        cancelButton.isHidden = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        //sortByTableView initialized
        sortByTableView.isScrollEnabled = true
        sortByTableView.delegate = self as! UITableViewDelegate
        sortByTableView.dataSource = self as! UITableViewDataSource
        //create identifier
        sortByTableView.register(SortByTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //addNewTableView initialized
        addNewTableView.isScrollEnabled = true
        addNewTableView.delegate = self as! UITableViewDelegate
        addNewTableView.dataSource = self as! UITableViewDataSource
        //create identifier
        addNewTableView.register(AddNewTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //MoreOptionsTableView initialized
        moreOptionsTableView.isScrollEnabled = true
        moreOptionsTableView.delegate = self as! UITableViewDelegate
        moreOptionsTableView.dataSource = self as! UITableViewDataSource
        //create identifier
        moreOptionsTableView.register(MoreOptionsTableViewCell.self, forCellReuseIdentifier: "Cell")

        //floating action bar
        fab.layer.cornerRadius = fab.frame.height/2
        fab.layer.shadowOpacity = 0.25
        fab.layer.shadowRadius = 5
        fab.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        //to make label clickable
        let tapSortBy = UITapGestureRecognizer(target: self, action: #selector(ClientViewController.tapSortBy))
        sortByTxt.isUserInteractionEnabled = true
        sortByTxt.addGestureRecognizer(tapSortBy)
        
        createProfileInfo()
        loadCurrentDirectory() //load data to collection view
        nodeList.append(extra)
        addFolder(newFolder: extra2)
        
        if (addedFolder != " "){
            addFolder(newFolder: Folder(nodeName: addedFolder))
            addedFolder = " "
        }
        
        //updateDirectory()
        //to go back to previous directory
        let tapGoBackButton = UITapGestureRecognizer(target: self, action: #selector(clickGoBackButton))
        goBackButton.isUserInteractionEnabled = true
        goBackButton.addGestureRecognizer(tapGoBackButton)
            
        
    } // end of line of viewDidLoad()
    
    //onlick function of tapSortBy
    //popup slide up menu
    @objc func tapSortBy(sender:UITapGestureRecognizer){
        let window = UIApplication.shared.keyWindow //to access nav controller
        //let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
        
        //change its color when pressed
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        
        //create tableView
        let screenSize = UIScreen.main.bounds.size
        sortByTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 100)
        window?.addSubview(sortByTableView)
        
        //to go back to original state
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.sortByTableView.frame = CGRect(x: 0, y: screenSize.height - 100, width: screenSize.width, height: 100)
        }, completion: nil)
        
    }

    //remove pop of from sortBy
    @objc func clickTransparentView(){
        let screenSize = UIScreen.main.bounds.size
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.sortByTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 100)
        }, completion: nil)
    }
    
    //add new folder/ upload file
    //popup slide up menu
    @IBAction func addNew(_ sender: Any) {
        
        let window = UIApplication.shared.keyWindow //to access nav controller
        
        //change its color when pressed
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        
        //create tableView
        let screenSize = UIScreen.main.bounds.size
        addNewTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 180)
        
        //make tableview header
        let headerView: UIView = UIView.init(frame: CGRect(x: 0,y: 0,width: screenSize.width,height: 30))
        let labelView: UILabel = UILabel.init(frame: CGRect(x: 4,y: 5,width: screenSize.width,height: 24))
        labelView.text = "Create New"
        labelView.textAlignment = .center
        headerView.addSubview(labelView)
        addNewTableView.tableHeaderView = headerView
        window?.addSubview(addNewTableView) //add tableview to window
        
        //to go back to original state
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickTransparentViewForAddNew))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.addNewTableView.frame = CGRect(x: 0, y: screenSize.height - 180, width: screenSize.width, height: 180)
        }, completion: nil)
    }

    //remove pop of from addNew
    @objc func clickTransparentViewForAddNew(){
        let screenSize = UIScreen.main.bounds.size
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.addNewTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 180)
        }, completion: nil)
    }
    
    /*---------*/
    /*functions*/
    /*---------*/
    private func addFile(addedFile : File){
        nodeList.append(addedFile)
        updateDirectory()
    }
    
    public func removeFile(removeFile : File){
        nodeList.removeAll(where: { $0 == removeFile}) // remove all elements that satisfy the predicate
        self.updateDirectory()
    }
    
    public func refreshAdapter(){
        collectionView.reloadData()
    }
    
    public func addFolder(newFolder : Folder){
        nodeList.append(newFolder)
        //addFolderDocumentPath(newFolderName: newFolder.getNodeName())
        //self.updateDirectory()
        //collectionView.reloadData()
        print("THE FILE ISSSSSS \(newFolder.getNodeName())")
    }
    
    public func addFolderDocumentPath(newFolderName: String){
        /*******************************/
        /*BE CAREFUL WITH OPTIONAL*/
        /*IT WILL CAUSE A LOT OF ERROR IN SENDING STUFF IN FIREBASE*/
        /*ESPECIALLY DOCUMENT REFERENCE PATH*/
         /*******************************/
        //for adding dir in new child
        let backSlash = "/"
        let newDocumentPath = documentPath + backSlash + newFolderName + backSlash + userId
        var arrFile: Array<Node> = Array()
        let dataToSave: [String : Any] = [
            "directory" : arrFile
        ]
        self.db.document(newDocumentPath).setData(dataToSave)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            }else{
                print("Document successfully written!")
            }
        }

    }
    
    private func updateDirectory(){
        self.db.document(documentPath).updateData(["directory" : nodeList])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            }else{
                print("Document successfully written!")
                self.refreshDirectory()
            }
        }
    } // end of updateDirectory
    
    public func moveFileUpdateDirectory(movedNodeList: Array<Node>){ //updated the previous directory of the moved file
        let movedFileDirectory: [String : Any] = [
            "directory" : movedNodeList
        ]
        self.db.document(documentPath).updateData(movedFileDirectory)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            }else{
                print("Document successfully written!")
                self.refreshDirectory()
            }
        }
        
    }
    
    public func refreshDirectory(){
        DispatchQueue.main.async {
            self.refreshAdapter()
        }
    }
    
    private func loadCurrentDirectory() {
        //Get data from fireStore
        nodeList.removeAll()
        print("Document PATH = \(documentPath)")
        if (documentPath == rootPath) {
            goBackButton.isHidden = true // hide the view
        } else {
            goBackButton.isHidden = false //unhide the view
        }
        db.document(documentPath).getDocument {
            (document, error) in
            if let document = document , document.exists {
                let users: Array<Any> = document.get("directory") as! Array<Any>
                for element in users {
                    let user: [String : Any] = element as! [String : Any]
                    let name: String = user["nodeName"] as! String
                    let isFolder: Bool = user["isFolder"] as! Bool
                    if(isFolder){
                        self.nodeList.append(Folder(nodeName: name))
                    }else{
                        let fileKey = user["fileKey"] as! String
                        let type = user["fileType"] as! String
                        let fileId = user["fileId"] as! Int
                        let fileSize = user["fileSize"] as! Int
                        self.nodeList.append(File(fileId: fileId, nodeName: name, fileSize: fileSize, fileType: type, fileKey: fileKey))
                    }
                }
                self.tempNodeList = self.nodeList
                self.refreshDirectory()
            } else {
                print("Document doesn't exist")
                let arrFile: Array<Node> = Array()
                let dataToSave: [String : Any] = [
                    "directory" : arrFile
                ]
                self.db.document(self.documentPath).setData(dataToSave)
                { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    }else{
                        print("Document successfully written!")
                    }
                }
            }
        }
    }
    

    //go back to previous directory
    @objc func clickGoBackButton(){
        removeCurrentDirectory()
        loadCurrentDirectory()
    }
    
    private func removeCurrentDirectory(){
        var countForBackslash = 0
        for i in stride(from: 1, through: documentPath.count, by: 1) {
            if(countForBackslash < 2){
                if(documentPath.last == "/"){
                    countForBackslash = countForBackslash + 1
                }
                documentPath = String(documentPath.dropLast())
            }
        }
        
    }
    
    private func searchFileFolder (fileFolderName : String) {
        
//        for element in tempNodeList {
//            nodeList.append(element)
//        }
        
        //filter the array
        nodeList = nodeList.filter({$0.getNodeName().lowercased().prefix(fileFolderName.count) == fileFolderName.lowercased()})

        refreshDirectory()
    }
    
    public func pressedMoveMoreOptions(fileToMove : File){
        var copyOfDocumentPath = documentPath
        moveFileDocumentPath = copyOfDocumentPath
        fileToMoveNodeList = nodeList
        isFileMoved = true //for more options
        collectionView.reloadData()
        moveHereButton.isHidden = false
        cancelButton.isHidden = false
        self.fileToMove = fileToMove
        
    }
    
    private func createProfileInfo(){ //add userProfile if it not exist in Firebase
        let firebaseAuth = Auth.auth()
        let email = firebaseAuth.currentUser!.email!
        let username = firebaseAuth.currentUser!.displayName!
        db.collection("Users").document(userId).getDocument {
            (document, error) in
            
            let currentUser:User = User(username: username, email: email, name: firebaseAuth.currentUser!.displayName!, dateOfBirth: Date(), region: "EU")
            let userPlan:Plan = Plan(planId: 1)
            currentUser.setPlan(plan: userPlan)
            
            if let document = document , !document.exists {
                var planData: [String : Any] = [
                    "planId" : currentUser.getPlan().getPlanId(),
                    "planStorage" : currentUser.getPlan().getPlanStorage(),
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
                self.db.collection("Users").document(self.userId).setData(user)
                 { err in
                     if let err = err {
                         print("Error writing document: \(err)")
                     }else{
                         print("Document successfully written!  \(currentUser.getPlan().getPlanStorage()) hjhjh")
                        
//                        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                        let MenuTVC:MenuTableViewController = storyboard.instantiateViewController(withIdentifier: "MenuTVC") as! MenuTableViewController
//
//                        self.db.collection("Users").document(self.userId).getDocument {
//                            (document, error) in
//                            if let document = document , document.exists {
//                                let username = document.get("Username")
//                                let email = document.get("Email")
//
//                                //set username and email in nav drawer
//                                if username as? String == "" {
//                                    MenuTVC.usernameTxt.text = "Username"
//                                }else {
//                                    MenuTVC.usernameTxt.text = username as? String
//                                }
//
//                                MenuTVC.emailTxt.text = email as? String
//                            } else {
//                                print("Document doesn't exist")
//                            }
//                        }
                     }
                 }
                
            } else {
                print("Document exist")
            }
        }
    } //end of function
    
    
    @IBAction func moveHereButtonPressed(_ sender: Any) {
        
        isFileMoved = false
        collectionView.reloadData()
        moveHereButton.isHidden = true
        cancelButton.isHidden = true
        
        if(moveFileDocumentPath == documentPath){
            print("You cant move on the same directory")
        } else {
            nodeList.append(fileToMove!)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        //var cell = ClientCollectionViewCell()
        //cell.moreOptions.isHidden = false
        isFileMoved = false
        collectionView.reloadData()
        moveHereButton.isHidden = true
        cancelButton.isHidden = true
    }
    
}

//nav drawer
extension ClientViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
    
}

//sortby tableview
extension ClientViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRowsInSec:Int!

        if tableView == addNewTableView {
            numOfRowsInSec = 1
        }
        else if tableView == sortByTableView{
            numOfRowsInSec = sortByList.count
        }else if tableView == moreOptionsTableView {
            numOfRowsInSec = moreOptionsList.count
        }

        return numOfRowsInSec
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView.isEqual(addNewTableView) {

            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AddNewTableViewCell

            cell.folder.text = "Folder"
            cell.secureUpload.text = "Secure Upload"
            cell.upload.text = "Upload"
            cell.folderImage.image = UIImage(systemName: "folder")
            cell.secureUploadImage.image = UIImage(systemName: "lock.shield")
            cell.uploadImage.image = UIImage(named: "icons8-upload-24")
            
            let tapUpload = UITapGestureRecognizer(target: self, action: #selector(ClientViewController.tapUpload))
            cell.upload.isUserInteractionEnabled = true
            cell.upload.addGestureRecognizer(tapUpload)
            
            let tapUploadImage = UITapGestureRecognizer(target: self, action: #selector(ClientViewController.tapUpload))
            cell.uploadImage.isUserInteractionEnabled = true
            cell.uploadImage.addGestureRecognizer(tapUploadImage)
            

            let tapSecureUpload = UITapGestureRecognizer(target: self, action: #selector(ClientViewController.tapSecureUpload))
            cell.secureUpload.isUserInteractionEnabled = true
            cell.secureUpload.addGestureRecognizer(tapSecureUpload)
            
            let tapSecureUploadImage = UITapGestureRecognizer(target: self, action: #selector(ClientViewController.tapSecureUpload))
            cell.secureUploadImage.isUserInteractionEnabled = true
            cell.secureUploadImage.addGestureRecognizer(tapSecureUploadImage)
            
            let tapFolder = UITapGestureRecognizer(target: self, action: #selector(ClientViewController.tapFolder))
            cell.folder.isUserInteractionEnabled = true
            cell.folder.addGestureRecognizer(tapFolder)
            
            let tapFolderImage = UITapGestureRecognizer(target: self, action: #selector(ClientViewController.tapFolder))
            cell.folderImage.isUserInteractionEnabled = true
            cell.folderImage.addGestureRecognizer(tapFolderImage)
            
            return cell

        }
        else if tableView == sortByTableView{
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SortByTableViewCell

            cell.title.text = sortByList[indexPath.row]
            cell.settingImage.image = sortByImage[indexPath.row]
            
            return cell
            
        }else if tableView == moreOptionsTableView{
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MoreOptionsTableViewCell

            cell.title.text = moreOptionsList[indexPath.row]
            cell.settingImage.image = moreOptionsImage[indexPath.row]
            
            return cell
        }else{
            return UITableViewCell()
        }
       
    }
    //select table view (sortby // moreOptions // addNew)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var showFile = self.nodeList[positionOfCell] as! File
        
        if tableView == addNewTableView {
            
        }else if tableView == sortByTableView{
            
        }else if tableView == moreOptionsTableView {
             if indexPath.row == 1 { // share
                print("THIS IS SHARE BUTTON")
             } else if indexPath.row == 2 { // download
                print("THIS IS DOWNLOAD BUTTON")
             } else if indexPath.row == 3 { // move
                print("THIS IS MOVE BUTTON")
                clickTransparentViewForMoreOptions()
                pressedMoveMoreOptions(fileToMove: showFile)
             } else if indexPath.row == 4 { // duplicate
                print("THIS IS DUPLICATE BUTTON")
             } else if indexPath.row == 5 { // details
                print("THIS IS DETAILS BUTTON")
                
                clickTransparentViewForMoreOptions()
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let fileDetailsController = storyboard.instantiateViewController(withIdentifier: "FileDetails") as! fileDetailsPopUpViewController
                fileDetailsController.fileName = self.nodeList[positionOfCell].getNodeName()
                fileDetailsController.fileSize = String(showFile.getFileSize())
                fileDetailsController.fileType = showFile.getFileType()
                let cardPopup = SBCardPopupViewController(contentViewController: fileDetailsController)
                cardPopup.show(onViewController: self)
                
             } else if indexPath.row == 6 { //backup
                print("THIS IS BACKUP BUTTON")
             } else if indexPath.row == 7 { // remove
                print("THIS IS REMOVE BUTTON")
                removefileFolder()
                clickTransparentViewForMoreOptions()
             }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == addNewTableView {
            return 150
        }else {
            return 50
        }
        
    }
    
    //onlick function of tapUpload
    @objc func tapFolder(sender:UITapGestureRecognizer){
        print("TAPPED FOLDER")
        //close pop up for add folder/upload file
        //-------------------------------
        let screenSize = UIScreen.main.bounds.size
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.addNewTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 180)
        }, completion: nil)
        //--------------------------
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addFolderController = storyboard.instantiateViewController(withIdentifier: "AddFolder") as! AddFolderPopUpViewController
        addFolderController.documentPath = documentPath
        addFolderController.fullDirectory = fullDirectory
        let cardPopup = SBCardPopupViewController(contentViewController: addFolderController)
        cardPopup.show(onViewController: self)
    }
    
    //onlick function of tapUpload
    @objc func tapSecureUpload(sender:UITapGestureRecognizer){
        print("TAPPED SECURE UPLOAD")
        
        //import document
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false //allow one file at a time
        present(documentPicker, animated:true, completion: nil)
        
    }
    
    //onlick function of tapUpload
    @objc func tapUpload(sender:UITapGestureRecognizer){
        print("TAPPED UPLOAD")
        
        //import document
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false //allow one file at a time
        present(documentPicker, animated:true, completion: nil)
    }
    
    //hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Functions for more option
    //remove file or folder in array and firebase
    private func removefileFolder(){
        print("Position ==== \(positionOfCell)")
        nodeList.remove(at: positionOfCell)
        nodeList.remove(at: positionOfCell)
        var updatedFullDirectory: String = ""
        let comma = ","
        for fileFolder in nodeList {
            updatedFullDirectory = updatedFullDirectory + comma + fileFolder.getNodeName()
        }
        let fullDirectoryToSave: [String : Any] = [
            "dir" : updatedFullDirectory
        ]
        db.document(documentPath).updateData(fullDirectoryToSave)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            }else{
                print("Document successfully written!")
            }
        }
        collectionView.reloadData()
    }
    
}


extension ClientViewController: UIDocumentPickerDelegate {
    
    //import document
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileUrl = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let sandboxFileURL = dir.appendingPathComponent(selectedFileUrl.path)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path){
            print ("file exists already")
        }else {
            
            do {
                try FileManager.default.copyItem(at: selectedFileUrl, to: sandboxFileURL)
                
                print("Copied file")
            }catch{
                print("Error: \(error)")
            }
            
        }
        
    }
     
}

//extentsion for collection view - size of cell and spacing
extension ClientViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

      let padding: CGFloat = 40
      let collectionCellSize = collectionView.frame.size.width - padding
        let collectionCellHeight = collectionView.frame.size.height - padding

        return CGSize(width: collectionCellSize/2, height: collectionCellHeight/2.3)

     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return sectionInset
    }

}

//for navigation controller
class ClientNavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
