//
//  ViewController.swift
//  DNA
//
//  Created by Adam Deming on 12/5/17.
//  Copyright © 2017 Adam Deming. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}

// Bottom Border TextField Extension
extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}


class ViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var labelTranslated: UILabel!
    @IBOutlet weak var transcribeButtonOutlet: UIButton!
    @IBOutlet weak var translateButtonOutlet: UIButton!
    @IBOutlet weak var singleLetterAminoAcidOutlet: UIButton!
    @IBOutlet weak var countLabel1: UILabel!
    @IBOutlet weak var countLabel2: UILabel!
    
    // Video Background
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    //
    var width: CGFloat!
    var height: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //create variables to simplify the positioning with fractions code
        width = view.frame.width
        height = view.frame.height
        print("VIEW WIDTH: \(view.frame.width)")
        print("VIEW HEIGHT: \(view.frame.height)")
        
//        // Mov Background
//        let URL = Bundle.main.url(forResource: "plant", withExtension: "mov")
//        player = AVPlayer.init(url: URL!)
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        playerLayer.frame = view.layer.frame
//        player.play()
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
//            self.player?.seek(to: kCMTimeZero)
//            self.player?.play()
//        }
//        view.layer.insertSublayer(playerLayer, at: 0)
        
        // TextField UI Setup
        textField.frame = CGRect(x: 40, y: height * 0.2, width: width-80, height: textField.frame.height)
        view.addSubview(textField)
        
        textField2.frame = CGRect(x: 40, y: height * 0.4, width: width-80, height: textField2.frame.height)
        view.addSubview(textField)
        
        textField.setBottomBorder()
        textField2.setBottomBorder()
        
        // Count Label UI Setup
        countLabel1.isHidden = true
        countLabel1.frame = CGRect(x: width * 0.074, y: height * 0.3, width: countLabel1.frame.width, height: countLabel1.frame.height)
        view.addSubview(countLabel1)
        
        countLabel2.isHidden = true
        countLabel2.frame = CGRect(x: width * 0.074, y: height * 0.5, width: countLabel2.frame.width, height: countLabel2.frame.height)
        view.addSubview(countLabel2)
        
        // Button UI Setup
        transcribeButtonOutlet.frame = CGRect(x: width * 0.42, y: height * 0.3, width: transcribeButtonOutlet.frame.width, height: transcribeButtonOutlet.frame.height)
        view.addSubview(transcribeButtonOutlet)
        
        translateButtonOutlet.frame = CGRect(x: width * 0.42, y: height * 0.5, width: translateButtonOutlet.frame.width, height: translateButtonOutlet.frame.height)
        view.addSubview(translateButtonOutlet)
        
        singleLetterAminoAcidOutlet.isHidden = true
        singleLetterAminoAcidOutlet.frame = CGRect(x: width * 0.79, y: height * 0.5, width: singleLetterAminoAcidOutlet.frame.width, height: singleLetterAminoAcidOutlet.frame.height)
        view.addSubview(singleLetterAminoAcidOutlet)
        
        // Label UI Setup
        labelTranslated.frame = CGRect(x: 40, y: height * 0.6, width: width-80, height: labelTranslated.frame.height)
        view.addSubview(labelTranslated)
        
        // Transparent Text Field
//        textField.alpha = 0.8
//        textField2.alpha = 0.8

        // Button Borders & Color
        transcribeButtonOutlet.setTitleColor(.white, for: .normal)
        transcribeButtonOutlet.layer.borderWidth = 0.5
        transcribeButtonOutlet.layer.borderColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        
        translateButtonOutlet.setTitleColor(.white, for: .normal)
        translateButtonOutlet.layer.borderWidth = 0.5
        translateButtonOutlet.layer.borderColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        
        singleLetterAminoAcidOutlet.setTitleColor(.white, for: .normal)
        singleLetterAminoAcidOutlet.layer.borderWidth = 0.5
        singleLetterAminoAcidOutlet.layer.borderColor = UIColor(white: 1.0, alpha:0.9).cgColor
        
        // Rounded Borders Text Fields
//        textField.borderStyle = UITextBorderStyle.roundedRect
//        textField2.borderStyle = UITextBorderStyle.roundedRect
        
        // Tap View to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Set textfield delegate for return key dismiss
        self.textField.delegate = self
        self.textField2.delegate = self
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func transcribeButton(_ sender: Any) {

        // Count Label
        countLabel1.isHidden = false
        countLabel1.text = "\(textField.text!.count)"
        
        var maturemRNA = ""
        //var complementaryRNA = ""
    
        // Letters that aren't G,C,A,T
        let nonNucleotideLetters = ["B","D","E","F","H","I","J","K","L","M","N","O","P","Q","R","S","U","V","W","X","Y","Z"]
        print(nonNucleotideLetters.count)
        
        for letter in nonNucleotideLetters {
            if textField.text!.contains(letter) {
                textField.text = "Nucleotide not recognized"
                //complementaryRNA = ""
                textField2.text = ""
                labelTranslated.text = ""
            }
        }
        
        for i in textField.text! {
            switch i {
            case "G":
                maturemRNA.append("G")
                textField2.text = maturemRNA
            case "A":
                maturemRNA.append("A")
                textField2.text = maturemRNA
            case "C":
                maturemRNA.append("C")
                textField2.text = maturemRNA
            case "T":
                maturemRNA.append("U")
                textField2.text = maturemRNA
            default:
                print(i)
            }
        }
        
        
//        // complementary mRNA transcription
//            for i in textField.text! {
//                switch i {
//                case "G":
//                    complementaryRNA.append("C")
//                    textField2.text = mRNA
//                case "A":
//                    complementaryRNA.append("U")
//                    textField2.text = mRNA
//                case "C":
//                    complementaryRNA.append("G")
//                    textField2.text = mRNA
//                case "T":
//                    complementaryRNA.append("A")
//                    textField2.text = mRNA
//                default:
//                    print(i)
//                }
        //            }
        

        textFieldShouldReturn(textField)
        
    }
    

    @IBAction func translateButton(_ sender: Any) {
        
        // Count Label
        countLabel2.isHidden = false
        countLabel2.text = "\(textField2.text!.count)"

        var codonTable = [
            "AUA":"Ile", "AUC":"Ile", "AUU":"Ile", "AUG":"Met",
            "ACA":"Thr", "ACC":"Thr", "ACG":"Thr", "ACU":"Thr",
            "AAC":"Asn", "AAU":"Asn", "AAA":"Lys", "AAG":"Lys",
            "AGC":"Ser", "AGU":"Ser", "AGA":"Arg", "AGG":"Arg",
            "CUA":"Leu", "CUC":"Leu", "CUG":"Leu", "CUU":"Leu",
            "CCA":"Pro", "CCC":"Pro", "CCG":"Pro", "CCU":"Pro",
            "CAC":"His", "CAU":"His", "CAA":"Gln", "CAG":"Gln",
            "CGA":"Arg", "CGC":"Arg", "CGG":"Arg", "CGU":"Arg",
            "GUA":"Val", "GUC":"Val", "GUG":"Val", "GUU":"Val",
            "GCA":"Ala", "GCC":"Ala", "GCG":"Ala", "GCU":"Ala",
            "GAC":"Asp", "GAU":"Asp", "GAA":"Glu", "GAG":"Glu",
            "GGA":"Gly", "GGC":"Gly", "GGG":"Gly", "GGU":"Gly",
            "UCA":"Ser", "UCC":"Ser", "UCG":"Ser", "UCU":"Ser",
            "UUC":"Phe", "UUU":"Phe", "UUA":"Leu", "UUG":"Leu",
            "UAC":"Tyr", "UAU":"Tyr", "UAA":"Stop", "UAG":"Stop",
            "UGC":"Cys", "UGU":"Cys", "UGA":"Stop", "UGG":"Trp",
            ]
        var numberOfCharacters = 0
        var rnaSequenceDebug = ""
        var RNA = ""
        var checkRNA = ""
        
        // Letters that aren't G,C,A,T
        let nonNucleotideLetters = ["B","D","E","F","H","I","J","K","L","M","N","O","P","Q","R","S","T","W","X","Y","Z"]
        print(nonNucleotideLetters.count)
        
        for letter in nonNucleotideLetters {
            if textField2.text!.contains(letter) {
                textField2.text = "Nucleotide not recognized"
                RNA = ""
                textField.text = ""
                labelTranslated.text = ""
            }
        }
        
        
            
        for i in textField2.text! {
            rnaSequenceDebug.append(String(i))
            checkRNA.append(String(i))
            numberOfCharacters += 1
            print(numberOfCharacters)
            
            if numberOfCharacters % 3 == 0 {

                rnaSequenceDebug.append("---")
                print(rnaSequenceDebug)

                for (codon,aminoAcid) in codonTable {
                    if checkRNA == codon {
                        RNA.append(aminoAcid)
                        RNA.append("-")
                        labelTranslated.text! = RNA
                        checkRNA.removeAll()
                        singleLetterAminoAcidOutlet.isHidden = false
                        print("TranslatedLabelCount: \(labelTranslated.text!.count)")
                    }
                
                }
            }

        }
        

        if labelTranslated.text!.contains("Stop") {
            
            let labelString = labelTranslated.text!
            let attributedString = NSMutableAttributedString(string: labelString)
            
            let highlightedWords = ["Stop"]

            for highlightedWord in highlightedWords {
                let textRange = (labelString as NSString).range(of: highlightedWord)
                
                if let font = UIFont(name: "Helvetica-Bold", size: 20) {
                    attributedString.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0, length: labelString.count))
                    attributedString.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.red, range: textRange)
                }
            }

        labelTranslated.attributedText = attributedString
        }

        // Return Keyboard
        textFieldShouldReturn(textField2)
  }
    
    var numberOfTaps = 0
    @IBAction func singleLetterAminoAcidButton(_ sender: Any) {

        let aminoDictionary = ["G":"Gly", "A":"Ala", "L":"Leu", "M":"Met", "F":"Phe", "W":"Trp", "K":"Lys", "Q":"Gln", "E":"Glu", "S":"Ser", "P":"Pro", "V":"Val", "I":"Ile", "C":"Cys", "Y":"Tyr", "H":"His", "R":"Arg", "N":"Asn", "D":"Asp", "T":"Thr"]
        var aminoAcidString = ""
        var checkAmino = ""
        var numberOfLetters = 0
        numberOfTaps+=1
        
        if numberOfTaps % 2 == 0 {
            print("numberOfTaps:\(numberOfTaps) is even")
            singleLetterAminoAcidOutlet.setTitle("single letter", for: .normal)
            
        } else {
            print("numberOfTaps:\(numberOfTaps) is odd")
            singleLetterAminoAcidOutlet.setTitle("three letter", for: .normal)
        }
        
        let aminosWithoutDashes = labelTranslated.text!.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range:nil)
        
        for n in aminosWithoutDashes {
            numberOfLetters += 1
            checkAmino.append(n)
            
            if numberOfLetters % 3 == 0 {
                
        for (singleLetter, threeLetter) in aminoDictionary {
            if checkAmino == threeLetter  {
                aminoAcidString.append(singleLetter)
                aminoAcidString.append("-")
                DispatchQueue.main.async{
                self.labelTranslated.text! = aminoAcidString
                }
                checkAmino.removeAll()
            }
            
                }
            }

        }

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

