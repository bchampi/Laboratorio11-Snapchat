//
//  ImagenViewController.swift
//  Snapchat
//
//  Created by Mac 17 on 6/2/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import Firebase

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var selectContactBtn: UIButton!
    
    var imagePicker = UIImagePickerController()
    var imageID = NSUUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        selectContactBtn.isEnabled = false
    }
    
    
    @IBAction func mediaTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectContactTapped(_ sender: Any) {
        self.selectContactBtn.isEnabled = false
        let imagesFolder = Storage.storage().reference().child("imagenes")
        let imageData = imageView.image?.jpegData(compressionQuality: 0.50)
        let loadImage = imagesFolder.child("\(imageID).jpg")
            loadImage.putData(imageData!, metadata: nil) { (metadata, error) in
            if error != nil {
                self.showAlert(title: "Error", message: "Se produjo un error al subir la imágen. Verifique su conexión a internet y vuelva a intentarlo", action: "Aceptar")
                self.selectContactBtn.isEnabled = true
                print("Se presentó el siguiente error al subir la imágen: \(String(describing: error))")
            } else {
                loadImage.downloadURL(completion: { (url, error) in
                    guard let _ = url else {
                        self.showAlert(title: "Error", message: "Se produjo un error al obtener información de la imagen", action: "Cancelar")
                        self.selectContactBtn.isEnabled = true
                        print("Ocurrio el siguiente error al obtener información de la imagen: \(error!)")
                        return
                    }
                    self.performSegue(withIdentifier: "selectContactSegue", sender: url?.absoluteString)
                })
                
            }
        }
        
        /*
        let loadAlert = UIAlertController(title: "Cargando Imágen...", message: "0%", preferredStyle: .alert)
        let progress: UIProgressView = UIProgressView(progressViewStyle: .default)
        loadImage.observe(.progress) { (snapshot) in
            let percentage = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print(percentage)
            progress.setProgress(Float(percentage), animated: true)
            progress.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
            loadAlert.message = String(round(percentage * 100.0)) + " %"
            if percentage >= 1.0 {
                loadAlert.dismiss(animated: true, completion: nil)
            }
        }
        
        let btnOk = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        loadAlert.addAction(btnOk)
        loadAlert.view.addSubview(progress)
        present(loadAlert, animated: true, completion: nil)
        */
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = imageSelected
        imageView.backgroundColor = UIColor.clear
        selectContactBtn.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnCancelOk = UIAlertAction(title: action, style: .default, handler: nil)
        alert.addAction(btnCancelOk)
        present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! SelectUserTableViewController
        nextVC.imageURL = sender as! String
        nextVC.descrip = descriptionTextField.text!
        nextVC.imageID = imageID
    }

}
