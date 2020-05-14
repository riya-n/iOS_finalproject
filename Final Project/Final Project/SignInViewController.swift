//
//  SignInViewController.swift
//  Final Project
//
//  Created by Riya Narayan on 17/4/20.
//  Copyright © 2020 Riya Narayan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        errorMsg.isHidden = true
    }
    
    @IBAction func didSelectCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSelectSignIn(_ sender: UIBarButtonItem) {
        Auth.auth().signIn(withEmail: email.text ?? "", password: password.text ?? "") { [weak self] (authResult, error) in
            if let error = error {
                // TODO: display error to user
                print(error.localizedDescription)
                self!.errorMsg.isHidden = false
                self!.errorMsg.text = "Error occured on Sign In"
                self!.errorMsg.textColor = UIColor.systemRed
            } else {
                print(authResult)
                self!.errorMsg.isHidden = true
                self?.performSegue(withIdentifier: "homeSegue", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeSegue" {
            if let homevc = segue.destination as? HomeViewController {
                // add delegates and data to send here
            }
        }
    }
    
    @IBAction func didSelectForgotPassword(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: email.text ?? "") { (error) in
            if let error = error {
                print(error.localizedDescription)
                self.errorMsg.isHidden = false
                self.errorMsg.text = "Error occured on Forget Password"
                self.errorMsg.textColor = UIColor.systemRed
            } else {
                self.errorMsg.isHidden = false
                self.errorMsg.text = "Email has been sent to reset password"
                self.errorMsg.textColor = UIColor.systemGray
            }
        }
    }
    
}
