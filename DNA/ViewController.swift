//
//  ViewController.swift
//  DNA
//
//  Created by Adam Deming on 12/5/17.
//  Copyright © 2017 Adam Deming. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var labelTranslated: UILabel!
    @IBOutlet weak var transcribeButtonOutlet: UIButton!
    @IBOutlet weak var translateButtonOutlet: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    // Video Background
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Mov Background
        let URL = Bundle.main.url(forResource: "plant", withExtension: "mov")
        player = AVPlayer.init(url: URL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = view.layer.frame
        player.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        }
        view.layer.insertSublayer(playerLayer, at: 0)
        
        // Transparent Text Field
        textField.alpha = 0.8
        textField2.alpha = 0.8
        
        // Button Borders & Color
        transcribeButtonOutlet.setTitleColor(.white, for: .normal)
        transcribeButtonOutlet.layer.borderWidth = 0.5
        transcribeButtonOutlet.layer.borderColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        translateButtonOutlet.setTitleColor(.white, for: .normal)
        translateButtonOutlet.layer.borderWidth = 0.5
        translateButtonOutlet.layer.borderColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        
        // Label Color
        headerLabel.textColor = UIColor.white
        
        // Tap View to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Set textfield delegate for return key dismiss
        self.textField.delegate = self
        self.textField2.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func transcribeButton(_ sender: Any) {
        var mRNA = ""
        
    
        // Letters that aren't G,C,A,T
        let nonNucleotideLetters = ["B","D","E","F","H","I","J","K","L","M","N","O","P","Q","R","S","U","V","W","X","Y","Z"]
        print(nonNucleotideLetters.count)
        
        for letter in nonNucleotideLetters {
            if textField.text!.contains(letter) {
                textField.text = "Nucleotide not recognized"
                mRNA = ""
                textField2.text = ""
            }
        }
        
        
            for i in textField.text! {
                switch i {
                case "G":
                    mRNA.append("C")
                    textField2.text = mRNA
                case "A":
                    mRNA.append("U")
                    textField2.text = mRNA
                case "C":
                    mRNA.append("G")
                    textField2.text = mRNA
                case "T":
                    mRNA.append("A")
                    textField2.text = mRNA
                default:
                    print(i)
                    
                }
        }
        
        
        
    }
    

    @IBAction func translateButton(_ sender: Any) {
        
     
    }
    
    // Return key tapped hides keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Dismisses keyboard when view is tapped
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}

