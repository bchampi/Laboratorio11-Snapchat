//
//  ImagenViewController.swift
//  Snapchat
//
//  Created by Mac 17 on 6/2/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var selectContactBtn: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var durationRecord: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nameAudioTextField: UITextField!
    
    var imagePicker = UIImagePickerController()
    var imageID = NSUUID().uuidString
    
    var recordAudio: AVAudioRecorder?
    var playAudio: AVAudioPlayer?
    var audioURL: URL?
    
    var timer: Timer = Timer()
    var count: Int = 0
    var timerCounting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordingConfiguration()
        imagePicker.delegate = self
        
        playButton.isEnabled = false
        playButton.tintColor = UIColor.lightGray
        selectContactBtn.isEnabled = false
        selectContactBtn.backgroundColor = UIColor.lightGray
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
    
    func recordingConfiguration() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("******************************")
            print(audioURL!)
            print("******************************")
            
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            recordAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            recordAudio!.prepareToRecord()
        }
        catch let error as NSError{
            print(error)
        }
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        if recordAudio!.isRecording {
            recordAudio?.stop()
            recordButton.setTitle("Grabar", for: .normal)
            playButton.isEnabled = true
            selectContactBtn.isEnabled = true
            self.selectContactBtn.backgroundColor = UIColor.link
            timerCounting = false
            timer.invalidate()
            durationRecord.textColor = UIColor.black
        }
        else {
            recordButton.setTitle("Detener", for: .normal)
            playButton.isEnabled = false
            recordAudio?.record()
            timerCounting = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            durationRecord.textColor = UIColor.systemBlue
        }
    }
    
    @objc func timerCounter() -> Void {
        count = count + 1
        let time = minutesAndSeconds(seconds: count)
        let timeString = makeTimeString(minutes: time.0, seconds: time.1)
        durationRecord.text = timeString
    }
    
    func minutesAndSeconds(seconds: Int) -> (Int, Int) {
        return (((seconds % 3600) / 60), (seconds % 3600) % 60)
    }
    
    func makeTimeString(minutes: Int, seconds: Int) -> String {
        var timerString = ""
        timerString += String(format: "%02d", minutes)
        timerString += ":"
        timerString += String(format: "%02d", seconds)
        return timerString
    }
    
    @IBAction func playTapped(_ sender: Any) {
        do {
            try playAudio = AVAudioPlayer(contentsOf: audioURL!)
            playAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func recordingVolume(_ sender: UISlider) {
        playAudio?.volume = sender.value
    }
    
    
    @IBAction func selectContactTapped(_ sender: Any) {
        selectContactBtn.isEnabled = false
        selectContactBtn.backgroundColor = UIColor.lightGray
        
        let imagesFolder = Storage.storage().reference().child("imagenes")
        let imageData = imageView.image?.jpegData(compressionQuality: 0.50)
        let loadImage = imagesFolder.child("\(imageID).jpg")
            loadImage.putData(imageData!, metadata: nil) { (metadata, error) in
            if error != nil {
                self.showAlert(title: "Error", message: "Se produjo un error al subir la imágen. Verifique su conexión a internet y vuelva a intentarlo", action: "Aceptar")
                self.selectContactBtn.isEnabled = false
                self.selectContactBtn.backgroundColor = UIColor.lightGray
                print("Se presentó el siguiente error al subir la imágen: \(String(describing: error))")
            } else {
                loadImage.downloadURL(completion: { (url, error) in
                    guard let _ = url else {
                        self.showAlert(title: "Error", message: "Se produjo un error al obtener información de la imagen", action: "Cancelar")
                        self.selectContactBtn.isEnabled = false
                        self.selectContactBtn.backgroundColor = UIColor.lightGray
                        print("Ocurrio el siguiente error al obtener información de la imagen: \(error!)")
                        return
                    }
                    self.performSegue(withIdentifier: "selectContactSegue", sender: url?.absoluteString)
                })
            }
        }
        
        let audiosFolder = Storage.storage().reference().child("audios")
        let audioData = NSData(contentsOf: audioURL!)! as Data
        let loadAudio = audiosFolder.child("\(audioData).mp3")
        loadAudio.putData(audioData, metadata: nil) { (metadata, error) in
        if error != nil {
            self.showAlert(title: "Error", message: "Se produjo un error al subir el audio. Verifique su conexión a internet y vuelva a intentarlo", action: "Aceptar")
            self.selectContactBtn.isEnabled = false
            self.selectContactBtn.backgroundColor = UIColor.lightGray
            print("Se presentó el siguiente error al subir el audio: \(String(describing: error))")
        } else {
            loadImage.downloadURL(completion: { (url, error) in
                guard let _ = url else {
                    self.showAlert(title: "Error", message: "Se produjo un error al obtener información del audio", action: "Cancelar")
                    self.selectContactBtn.isEnabled = false
                    self.selectContactBtn.backgroundColor = UIColor.lightGray
                    print("Ocurrio el siguiente error al obtener información del audio: \(error!)")
                    return
                }
            })}
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
        self.selectContactBtn.backgroundColor = UIColor.link
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
