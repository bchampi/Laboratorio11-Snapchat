//
//  LogInViewController.swift
//  Snapchat
//
//  Created by Mac 17 on 5/27/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn
import FacebookLogin

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            self.showHome(result: result, error: error, typeAuth: "Correo y contraseña")
        }
    }
    
    @IBAction func logInGoogleTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func logInFacebookTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions: [.email], viewController: self) { (result) in
            switch result {
            case .success(granted: _, declined: _, token: let token):
                let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
                
                Auth.auth().signIn(with: credential) { (result, error) in
                    self.showHome(result: result, error: error, typeAuth: "Facebook")
                }
                
            case .cancelled:
                break
            case .failed(_):
                break
            }
        }
    }
    
    private func showHome(result: AuthDataResult?, error: Error?, typeAuth: String) {
        print("Intentando Iniciar Sesión")
        if let result = result, error == nil {
            print("Inicio de sesión exitoso con la cuenta: \(result.user.email!), mediante \(typeAuth)")
            self.performSegue(withIdentifier: "logInSegue", sender: nil)
        } else {
            print("Se presentó el siguiente error: \(String(describing: error))")
            if typeAuth == "Correo y contraseña" {
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (result, error) in
                    print("Intentando crear usuario")
                    if let result = result, error == nil {
                        print("El usuario con correo electrónico: \(result.user.email!), fue creado exitosamente con el proveedor \(typeAuth)")
                        
                        self.database.child("usuarios").child(result.user.uid).child("email").setValue(result.user.email)
                        
                        let alert = UIAlertController(title: "Creación de un Usuario", message: "Usuario: \(self.emailTextField.text!) se creó correctamente", preferredStyle: .alert)
                        let btnOk = UIAlertAction(title: "Aceptar", style: .default, handler: { (UIAlertAction) in
                            self.performSegue(withIdentifier: "logInSegue", sender: nil)
                        })
                        alert.addAction(btnOk)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print("Se presentó el siguiente error al crear un usuario: \(String(describing: error))")
                    }
                })
            }
        }
    }
}

extension LogInViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user.authentication != nil {
            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                self.showHome(result: result, error: error, typeAuth: "Google")
            }
        }
    }
}

// user@gmail.com user1@empresa.com - 123456
// Auth Google brayan.champi@tecsup.edu.pe
