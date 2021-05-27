//
//  LogInViewController.swift
//  Snapchat
//
//  Created by Mac 17 on 5/27/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            print("Intentando Iniciar Sesión")
            if error != nil {
                print("Se presentó el siguiente error: \(error)")
            } else {
                print("Inicio de sesión exitoso")
            }
        }
    }
    
}

// user@gmail.com 123456789
