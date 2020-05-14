//
//  SignUpViewController.swift
//  Final Project
//
//  Created by Riya Narayan on 17/4/20.
//  Copyright © 2020 Riya Narayan. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        errorMsg.isHidden = true
    }
    
    @IBAction func didSelectCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSelectSignUp(_ sender: UIBarButtonItem) {
        if (firstName.text != "" && lastName.text != "" && email.text != "" && email.text != "" && password.text != "" && confirmPassword.text != "" && password.text == confirmPassword.text) {
            Auth.auth().createUser(withEmail: email.text ?? "", password: confirmPassword.text ?? "") { (authResult, error) in
                if let error = error {
                    // TODO: display error to user
                    print(error.localizedDescription)
                    self.errorMsg.isHidden = false
                    self.errorMsg.text = "Error occured on Sign Up"
                    self.errorMsg.textColor = UIColor.systemRed
                } else {
                    print(authResult)
                    self.errorMsg.isHidden = true
                    let user = authResult?.user
                    if let user = user {
                        let newUser = [
                            "firstName": self.firstName.text ?? "",
                            "lastName": self.lastName.text ?? "",
                            "email": self.email.text ?? "",
                            "followers": "",
                            "following": ""
                        ]
                    self.ref.child("users").child(user.uid).setValue(newUser)
                }
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                }
            }
        } else {
            self.errorMsg.isHidden = false
            self.errorMsg.text = "Please enter all fields correctly"
            self.errorMsg.textColor = UIColor.systemRed
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeSegue" {
            if let homevc = segue.destination as? HomeViewController {
                // add delegates and data to send here
            }
        }
    }
    
}
