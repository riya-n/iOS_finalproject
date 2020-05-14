//
//  StartViewController.swift
//  Final Project
//
//  Created by Riya Narayan on 17/4/20.
//  Copyright © 2020 Riya Narayan. All rights reserved.
//

import UIKit
import Foundation

class StartViewController : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didSelectSignUp(_ sender: UIButton) {
        performSegue(withIdentifier: "signUpSegue", sender: nil)
    }
    
    @IBAction func didSelectSignIn(_ sender: UIButton) {
        performSegue(withIdentifier: "signInSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpSegue" {
            if let navVC = segue.destination as? UINavigationController {
                if let signupvc = navVC.topViewController as? SignUpViewController {
                    // add delegates and data to send here
                }
            }
        }
        if segue.identifier == "signInSegue" {
            if let navVC = segue.destination as? UINavigationController {
                if let signinvc = navVC.topViewController as? SignInViewController {
                    // add delegates and data to send here
                }
            }
        }
    }
    
}
