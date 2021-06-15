//
//  SnapsTableViewController.swift
//  Snapchat
//
//  Created by Mac 17 on 6/9/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SnapsTableViewController: UITableViewController {
    
    var snaps: [Snap] = []
    private let database = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        database.child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").observe(DataEventType.childAdded, with: { (snapshot) in
            let snap = Snap()
            snap.imagURL = (snapshot.value as! NSDictionary)["imageURL"] as! String
            snap.from = (snapshot.value as! NSDictionary)["from"] as! String
            snap.descrip = (snapshot.value as! NSDictionary)["description"] as! String
            snap.imageID = (snapshot.value as! NSDictionary)["imageID"] as! String
            
            snap.audioURL = (snapshot.value as! NSDictionary)["audioURL"] as! String
            snap.audioID = (snapshot.value as! NSDictionary)["audioID"] as! String
            snap.audioDuration = (snapshot.value as! NSDictionary)["audioDuration"] as! String
            snap.audioName = (snapshot.value as! NSDictionary)["audioName"] as! String
            
            snap.id = snapshot.key
            self.snaps.append(snap)
            self.tableView.reloadData()
        })
        
        database.child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").observe(DataEventType.childRemoved, with: { (snapshot) in
            var iterator = 0
            for snap in self.snaps {
                if snap.id == snapshot.key {
                    self.snaps.remove(at: iterator)
                }
                iterator += 1
            }
            self.tableView.reloadData()
        })
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snaps.count != 0 ? snaps.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSnaps", for: indexPath)
        if snaps.count == 0 {
            cell.textLabel?.text = "No tienes Snaps 😭"
        } else {
            let snap = snaps[indexPath.row]
            cell.textLabel?.text = snap.from
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snap = snaps[indexPath.row]
        performSegue(withIdentifier: "showSnapSegue", sender: snap)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSnapSegue" {
            let nextVC = segue.destination as! ShowSnapViewController
            nextVC.snap = sender as! Snap
        }
    }

}
