//
//  SignInViewController.swift
//  Snapchat
//
//  Created by Mac 17 on 6/6/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailSignInTextField: UITextField!
    @IBOutlet weak var passwordSignInTextField: UITextField!
    
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func returnLogInTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createUserTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.emailSignInTextField.text!, password: self.passwordSignInTextField.text!, completion: { (result, error) in
            print("Intentando crear usuario")
            if error == nil {
                print("El usuario con correo electrónico: \(result!.user.email!), fue creado exitosamente")
                self.database.child("usuarios").child(result!.user.uid).child("email").setValue(result!.user.email)
                self.showAlert()

            } else {
                print("Se presentó el siguiente error al crear un usuario: \(String(describing: error))")
            }
        })
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Creando Usuario", message: "El usuario con correo \(self.emailSignInTextField.text!), se creó correctamente", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    /*

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
