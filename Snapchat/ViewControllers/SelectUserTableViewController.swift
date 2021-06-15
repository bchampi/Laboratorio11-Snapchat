//
//  SelectUserTableViewController.swift
//  Snapchat
//
//  Created by Mac 17 on 6/4/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SelectUserTableViewController: UITableViewController {
    
    let database = Database.database().reference()
    var users: [User] = []
    var imageURL = ""
    var descrip = ""
    var imageID = ""
    
    var audioURL = ""
    var audioID = ""
    var audioName = ""
    var audioDuration = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        database.child("usuarios").observe(DataEventType.childAdded, with: { (snapshot) in
            let user = User()
            user.email = (snapshot.value as! NSDictionary)["email"] as! String
            user.uid = snapshot.key
            self.users.append(user)
            self.tableView.reloadData()
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count != 0 ? users.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if users.count == 0 {
            cell.textLabel?.text = "No tienes usuarios registrados 😭"
        } else {
            let user = users[indexPath.row]
            cell.textLabel?.text = user.email
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let snap = ["from": user.email, "description": descrip, "imageURL": imageURL, "imageID": imageID, "audioURL": audioURL, "audioID": audioID, "audioDuration": audioDuration, "audioName": audioName]
        database.child("usuarios").child(user.uid).child("snaps").childByAutoId().setValue(snap)
        navigationController?.popViewController(animated: true)
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
