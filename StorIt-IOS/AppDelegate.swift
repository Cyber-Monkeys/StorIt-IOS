//
//  AppDelegate.swift
//  StorIt-IOS
//
//  Created by Amad Khan on 24/12/2019.
//  Copyright © 2019 Cyber-Monkeys. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }
    
    struct AppUtility {

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

            self.lockOrientation(orientation)

            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }

    }//end of orientation lock code
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        return
      }
        
        guard let authentication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        //use Firestore
        let db = Firestore.firestore()
        var datePicker : UIDatePicker?
        Auth.auth().signIn(with: credential) { (result, error) in
            if error == nil {

                print(result?.user.email)
                print(result?.user.displayName)

                //set data to fireStore
                let firebaseAuth = Auth.auth()
                var userId = firebaseAuth.currentUser!.uid
                let dataToSave: [String : Any] = [
                    "Username" : firebaseAuth.currentUser!.displayName,
                    "Name" : "",
                    "Email" : firebaseAuth.currentUser!.email,
                    "Birthdate" : datePicker?.date
                ]

                //check if document exists
//                db.collection("Users").document(userId).getDocument {
//                    (document, error) in
//                    if let document = document , document.exists {
//                        print("Document does exist")
//                    } else {
//                        print("Document doesn't exist")
//                        db.collection("Users").document(userId).setData(dataToSave)
//                        { err in
//                            if let err = err {
//                                print("Error writing document: \(err)")
//                            }else{
//                                print("Document successfully written!")
//                            }
//                        }
//                    }
//                }

            }else{
                print(error?.localizedDescription)
            }
        }
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        let db = Firestore.firestore() //access FireStore
        GIDSignIn.sharedInstance()?.clientID = "987406483611-usp87d268vbsm1loo3ebbdnor0f22fho.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "StorIt_IOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

