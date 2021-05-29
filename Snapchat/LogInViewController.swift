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
import GoogleSignIn

class LogInViewController: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            self.showHome(result: result, error: error)
        }
    }
    
    @IBAction func logInGoogleTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    private func showHome(result: AuthDataResult?, error: Error?) {
        print("Intentando Iniciar Sesión")
        if let result = result, error == nil {
            print("Inicio de sesión exitoso con la cuenta: \(result.user.email!)")
        } else {
            print("Se presentó el siguiente error: \(String(describing: error))")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("Si")
        if error == nil && user.authentication != nil {
            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                self.showHome(result: result, error: error)
            }
        }
    }
    
}

// user@gmail.com 123456789
// Auth Google brayan.champi@tecsup.edu.pe T3csup7086
