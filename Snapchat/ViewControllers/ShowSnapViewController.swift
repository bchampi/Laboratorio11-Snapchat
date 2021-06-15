//
//  ShowSnapViewController.swift
//  Snapchat
//
//  Created by Mac 17 on 6/13/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class ShowSnapViewController: UIViewController {

    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var labelAudio: UILabel!
    @IBOutlet weak var labelDurationRecord: UILabel!
    
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    var snap = Snap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = snap.from

        labelMessage.text = snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagURL), completed: nil)
        
        labelAudio.text = snap.audioName
        labelDurationRecord.text = snap.audioDuration
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        database.child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        storage.child("imagenes").child("\(snap.imageID).jpg").delete { (error) in
            print("Se eliminó la imagen correctamente")
        }
        
        storage.child("audios").child("\(snap.audioID).mp3").delete { (error) in
            print("Se eliminó el audio correctamente")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
