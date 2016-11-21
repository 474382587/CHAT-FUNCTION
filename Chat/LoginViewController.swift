//
//  LoginViewController.swift
//  Chat
//
//  Created by Joseph on 16/11/7.
//  Copyright © 2016年 Joseph. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var Login: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        FIRAuth.auth()?.addAuthStateDidChangeListener({(auth: FIRAuth, user: FIRUser?)in
            if user != nil{
                print(user)
                
                Helper.helper.switchToNavigationViewController()
                
            }else{
            print("unauthorized")
            }
            })
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(FIRAuth.auth()?.currentUser)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func LoginTapped(sender: AnyObject) {
        
        print("login tapped")
        
        Helper.helper.LoginTapped()

        
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
