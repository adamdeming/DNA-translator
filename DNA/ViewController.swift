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


class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    // Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var labelTranslated: UILabel!
    @IBOutlet weak var transcribeButtonOutlet: UIButton!
    @IBOutlet weak var translateButtonOutlet: UIButton!
    @IBOutlet weak var countLabel1: UILabel!
    @IBOutlet weak var countLabel2: UILabel!

    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var trailingC: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var readingFrameValueLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var menuIsVisible = false
    var originalString = ""
    // Video Background
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!

    
    //
    var width: CGFloat!
    var height: CGFloat!
    
    var tableViewArray = [String]()
    var historyArrayDNA = [String]()
    var historyArrayRNA = [String]()
    
    var transcribedTapped = false

//    let navTitle = UILabel()
    
    var collectionItems = [String]()
    var collectionItemsSingleLetter = [String]()
    
    var isSingleLetter = false
    
    var isAction = true

    var sortedArray = [String]()
    
    let defaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //create variables to simplify the positioning with fractions code
        width = view.frame.width
        height = view.frame.height
        print("VIEW WIDTH: \(view.frame.width)")
        print("VIEW HEIGHT: \(view.frame.height)")
        
        if width == 812 {
           iphone10UI()
        }
        else if width == 896 {
            iphoneXSUI()
        }
        else {
            otherIphoneUI()
        }
        
        textField.setBottomBorder()
        textField2.setBottomBorder()
        // Tap View to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        mainView.addGestureRecognizer(tap)
    
        // Set textfield delegate for return key dismiss
        self.textField.delegate = self
        self.textField2.delegate = self
        
        // Gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // Table View Delegate
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Set History Title
//                navTitle.text = "history"
//                navTitle.sizeToFit()
//                navTitle.isHidden = true
//                navTitle.frame = CGRect(x: 0, y: 0, width: 250, height: 30)
//                navTitle.textColor = UIColor.darkGray
//
        
        // Clear Button
        
        //        editButton.setTitle("Edit", for: .normal)
        //        editButton.setTitleColor(UIColor.darkGray, for: .normal)
        //        editButton.isHidden = true
        
        
        // Bar Buttons
//        let iconItem = UIBarButtonItem(customView: iconView)
        
        editButtonItem.tintColor = UIColor.darkGray
        self.navigationItem.leftBarButtonItems = [menuButton]
        
        if (defaults.value(forKey: "historyAmino") != nil) {
            tableViewArray = (defaults.array(forKey: "historyAmino") as? [String])!
            historyArrayDNA = (defaults.array(forKey: "historyDNA") as? [String])!
            historyArrayRNA = (defaults.array(forKey: "historyRNA") as? [String])!
        } else {
            tableViewArray = []
            historyArrayDNA = []
            historyArrayRNA = []
            defaults.set(tableViewArray, forKey: "historyAmino") //setObject
            defaults.set(historyArrayDNA, forKey: "historyDNA")
            defaults.set(historyArrayRNA, forKey: "historyRNA")
            defaults.synchronize()
        }
        tableView.reloadData()
        
        tableView.showsVerticalScrollIndicator = false
        
        // Gets Rid of Naviagation Bar Line
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
//                // Uncomment to clear NSUserDefaults
//                defaults.removeObject(forKey: "historyAminoArrayKey")
//                defaults.removeObject(forKey: "DNAKey")
//                defaults.removeObject(forKey: "RNAKey")
        
        // Listeners for Clear Button Clicked
        textField.addTarget(self, action: #selector(textFieldListener(textField:)), for: UIControlEvents.allEditingEvents)
        textField2.addTarget(self, action: #selector(textField2Listener(textField2:)), for: UIControlEvents.allEditingEvents)
        
        print("Transcribe XY: \(transcribeButtonOutlet.frame.origin.x),\(transcribeButtonOutlet.frame.origin.y)")
        print("Translate XY: \(translateButtonOutlet.frame.origin.x),\(translateButtonOutlet.frame.origin.y)")
        print("Count Label 1 XY: \(countLabel1.frame.origin.x),\(countLabel1.frame.origin.y)")
        print("Count Label 2 XY: \(countLabel2.frame.origin.x),\(countLabel2.frame.origin.y)")
        print("Collection View XY: \(collectionView.frame.origin.x),\(collectionView.frame.origin.y)")
        print("Stepper XY: \(stepper.frame.origin.x),\(stepper.frame.origin.y)")
        print("Reading Frame Label XY: \(readingFrameValueLabel.frame.origin.x),\(readingFrameValueLabel.frame.origin.y)")
        
        
    }
    

    
    func otherIphoneUI() {
        tableView.frame = CGRect(x: 0, y: 0, width: width * 0.5, height: height - 50)
        view.addSubview(tableView)
        
        view.addSubview(mainView)
        // TextField UI Setup
        textField.frame = CGRect(x: 40, y: height * 0.1, width: width-80, height: textField.frame.size.height)
        mainView.addSubview(textField)
        
        textField2.frame = CGRect(x: 40, y: height * 0.3, width: width-80, height: textField2.frame.size.height)
        mainView.addSubview(textField)
    
        
        // Count Label UI Setup
        countLabel1.frame = CGRect(x: 40, y: height * 0.2, width: countLabel1.frame.size.width, height: countLabel1.frame.size.height)
        mainView.addSubview(countLabel1)
        countLabel1.text = "0"
        countLabel2.frame = CGRect(x: 40, y: height * 0.4, width: countLabel2.frame.size.width, height: countLabel2.frame.size.height)
        mainView.addSubview(countLabel2)
        countLabel2.text = "0"
        
//        complementButtonOutlet.frame = CGRect(x: (width-40) - complementButtonOutlet.frame.size.width, y: textField.frame.origin.y + 40, width: complementButtonOutlet.frame.size.width, height: complementButtonOutlet.frame.size.height)
//        mainView.addSubview(complementButtonOutlet)
//        complementButtonOutlet.isHidden = true
//
        // Label UI Setup
        labelTranslated.frame = CGRect(x: 80, y: 20, width: width-80, height: labelTranslated.frame.size.height)
        labelTranslated.isHidden = true
        
        collectionView.frame = CGRect(x: 40, y: height * 0.5, width: width-80, height: collectionView.frame.size.height)
        mainView.addSubview(collectionView)
        collectionView.isHidden = true
        
        // Button UI Setup
        transcribeButtonOutlet.frame = CGRect(x: (width / 2) - (transcribeButtonOutlet.frame.size.width/2), y: height * 0.2, width: transcribeButtonOutlet.frame.size.width, height: transcribeButtonOutlet.frame.size.height)
        mainView.addSubview(transcribeButtonOutlet)
        
        translateButtonOutlet.frame = CGRect(x: (width / 2) - (translateButtonOutlet.frame.size.width/2), y: height * 0.43, width: translateButtonOutlet.frame.size.width, height: translateButtonOutlet.frame.size.height)
        mainView.addSubview(translateButtonOutlet)
        
        stepper.frame = CGRect(x: 40, y: height * 0.73, width: stepper.frame.size.width, height: stepper.frame.size.height)
        mainView.addSubview(stepper)
        stepper.isHidden = true
        
        readingFrameValueLabel.frame = CGRect(x: 35, y: height * 0.8, width: readingFrameValueLabel.frame.size.width, height: readingFrameValueLabel.frame.size.height)
        mainView.addSubview(readingFrameValueLabel)
        readingFrameValueLabel.isHidden = true
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 20, width: 16, height: 30))
        iconView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "DNAStrandSolo")
        iconView.image = image
        
        navigationItem.titleView = iconView
        
        if height > 415 {
            countLabel1.frame = CGRect(x: 40, y: height * 0.15, width: countLabel1.frame.size.width, height: countLabel1.frame.size.height)
            countLabel2.frame = CGRect(x: 40, y: height * 0.35, width: countLabel2.frame.size.width, height: countLabel2.frame.size.height)
            
            collectionView.frame = CGRect(x: 40, y: height * 0.5, width: width-80, height: collectionView.frame.size.height)
            
            stepper.frame = CGRect(x: 40, y: height * 0.6, width: stepper.frame.size.width, height: stepper.frame.size.height)
            
                    readingFrameValueLabel.frame = CGRect(x: 35, y: height * 0.64, width: readingFrameValueLabel.frame.size.width, height: readingFrameValueLabel.frame.size.height)
        }
    }
    func iphone10UI() {
        tableView.frame = CGRect(x: 0, y: 0, width: width * 0.5, height: height - 50)
        view.addSubview(tableView)
        
        view.addSubview(mainView)
        // TextField UI Setup
        textField.frame = CGRect(x: 40, y: height * 0.1, width: width-150, height: textField.frame.size.height)
        mainView.addSubview(textField)
        
        textField2.frame = CGRect(x: 40, y: height * 0.3, width: width-150, height: textField2.frame.size.height)
        mainView.addSubview(textField2)
        
        // Count Label UI Setup
        countLabel1.frame = CGRect(x: 40, y: height * 0.2, width: countLabel1.frame.size.width, height: countLabel1.frame.size.height)
        mainView.addSubview(countLabel1)
        countLabel1.text = "0"
        countLabel2.frame = CGRect(x: 40, y: height * 0.4, width: countLabel2.frame.size.width, height: countLabel2.frame.size.height)
        mainView.addSubview(countLabel2)
        countLabel2.text = "0"
        
//        complementButtonOutlet.frame = CGRect(x: (width-40) - complementButtonOutlet.frame.size.width, y: textField.frame.origin.y + 40, width: complementButtonOutlet.frame.size.width, height: complementButtonOutlet.frame.size.height)
//        mainView.addSubview(complementButtonOutlet)
//        complementButtonOutlet.isHidden = true
        
        // Label UI Setup
        labelTranslated.frame = CGRect(x: stepper.frame.origin.x + 100, y: textField2.frame.origin.y + 80 , width: width-80, height: labelTranslated.frame.size.height)
        labelTranslated.isHidden = true
        
        collectionView.frame = CGRect(x: 40, y: height * 0.5, width: width-80, height: collectionView.frame.size.height)
        mainView.addSubview(collectionView)
        collectionView.isHidden = true
        
        // Button UI Setup
        transcribeButtonOutlet.frame = CGRect(x: (width / 2.26) - (transcribeButtonOutlet.frame.size.width/2.2), y: height * 0.2, width: transcribeButtonOutlet.frame.size.width, height: transcribeButtonOutlet.frame.size.height)
        mainView.addSubview(transcribeButtonOutlet)
        
        translateButtonOutlet.frame = CGRect(x: (width / 2.26) - (translateButtonOutlet.frame.size.width/2.2), y: height * 0.43, width: translateButtonOutlet.frame.size.width, height: translateButtonOutlet.frame.size.height)
        mainView.addSubview(translateButtonOutlet)
        
        
        stepper.frame = CGRect(x: 40, y: height * 0.73, width: stepper.frame.size.width, height: stepper.frame.size.height)
        mainView.addSubview(stepper)
        stepper.isHidden = true
        
        readingFrameValueLabel.frame = CGRect(x: 35, y: height * 0.8, width: readingFrameValueLabel.frame.size.width, height: readingFrameValueLabel.frame.size.height)
        mainView.addSubview(readingFrameValueLabel)
        readingFrameValueLabel.isHidden = true

        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 15, width: 16, height: 30))
        iconView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "DNAStrandSolo")
        iconView.image = image
        
        navigationItem.titleView = iconView
        
        
    }
    
    func iphoneXSUI() {
        tableView.frame = CGRect(x: 0, y: 0, width: width * 0.5, height: height - 50)
        view.addSubview(tableView)
        tableView.isHidden = true
        
        view.addSubview(mainView)
        // TextField UI Setup
        textField.frame = CGRect(x: 40, y: height * 0.1, width: width-165, height: textField.frame.size.height)
        mainView.addSubview(textField)
        
        textField2.frame = CGRect(x: 40, y: height * 0.3, width: width-165, height: textField2.frame.size.height)
        mainView.addSubview(textField2)
        
        // Count Label UI Setup
        countLabel1.frame = CGRect(x: 40, y: height * 0.2, width: countLabel1.frame.size.width, height: countLabel1.frame.size.height)
        mainView.addSubview(countLabel1)
        countLabel1.text = "0"
        countLabel2.frame = CGRect(x: 40, y: height * 0.4, width: countLabel2.frame.size.width, height: countLabel2.frame.size.height)
        mainView.addSubview(countLabel2)
        countLabel2.text = "0"
        
        //        complementButtonOutlet.frame = CGRect(x: (width-40) - complementButtonOutlet.frame.size.width, y: textField.frame.origin.y + 40, width: complementButtonOutlet.frame.size.width, height: complementButtonOutlet.frame.size.height)
        //        mainView.addSubview(complementButtonOutlet)
        //        complementButtonOutlet.isHidden = true
        
        // Label UI Setup
        labelTranslated.frame = CGRect(x: stepper.frame.origin.x + 100, y: textField2.frame.origin.y + 80 , width: width-80, height: labelTranslated.frame.size.height)
        labelTranslated.isHidden = true
        
        collectionView.frame = CGRect(x: 40, y: height * 0.5, width: width-160, height: collectionView.frame.size.height)
        mainView.addSubview(collectionView)
        collectionView.isHidden = true
        
        // Button UI Setup
        transcribeButtonOutlet.frame = CGRect(x: (width / 2.26) - (transcribeButtonOutlet.frame.size.width/2.2), y: height * 0.2, width: transcribeButtonOutlet.frame.size.width, height: transcribeButtonOutlet.frame.size.height)
        mainView.addSubview(transcribeButtonOutlet)
        
        translateButtonOutlet.frame = CGRect(x: (width / 2.24) - (translateButtonOutlet.frame.size.width/2.24), y: height * 0.43, width: translateButtonOutlet.frame.size.width, height: translateButtonOutlet.frame.size.height)
        mainView.addSubview(translateButtonOutlet)
        
        
        stepper.frame = CGRect(x: 40, y: height * 0.73, width: stepper.frame.size.width, height: stepper.frame.size.height)
        mainView.addSubview(stepper)
        stepper.isHidden = true
        
        readingFrameValueLabel.frame = CGRect(x: 35, y: height * 0.8, width: readingFrameValueLabel.frame.size.width, height: readingFrameValueLabel.frame.size.height)
        mainView.addSubview(readingFrameValueLabel)
        readingFrameValueLabel.isHidden = true
        
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 15, width: 16, height: 30))
        iconView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "DNAStrandSolo")
        iconView.image = image
        
        navigationItem.titleView = iconView
        
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func textFieldListener(textField: UITextField) {

        dnaKeyboard()

        textField.text! = textField.text!.uppercased()
        textField.text! = removeSpecialCharsFromString(text: textField.text!)
        countLabel1.text = "\(textField.text!.count)"
        reverseTranscribe()
        
        stepper.value = 1
        stepper.isHidden = true
        readingFrameValueLabel.isHidden = true
        collectionView.isHidden = true
        isAction = true
        
        if textField.text == "" {
            labelTranslated.text = ""
            textField2.text = ""
        }
        
        stepper.value = 1
        readingFrameValueLabel.text = "reading frame: \(Int(stepper.value))"
        originalString = textField2.text!
        
    
        
    }
    
    @objc func textField2Listener(textField2: UITextField) {
        
        rnaKeyboard()
        
        textField2.text! = textField2.text!.uppercased()
        textField2.text! = removeSpecialCharsFromString(text: textField2.text!)
        countLabel2.text = "\(textField2.text!.count)"
        reverseTranslate()

        stepper.isHidden = true
        readingFrameValueLabel.isHidden = true
        collectionView.isHidden = true
        isAction = true
        
        if textField2.text == "" {
            labelTranslated.text = ""
            originalString = ""
        }
        
        stepper.value = 1
        readingFrameValueLabel.text = "reading frame: \(Int(stepper.value))"
        originalString = textField2.text!
        
        
    }
    
    @IBAction func transcribeButton(_ sender: Any) {
        
        stepper.value = 1
        readingFrameValueLabel.text = "reading frame: \(Int(stepper.value))"
        
        // Count Label
        countLabel1.text = "\(textField.text!.count)"
        countLabel2.text = "\(textField.text!.count)"
        
        var maturemRNA = ""
        
        // Letters that aren't G,C,A,T
        let nonNucleotideLetters = ["B","D","E","F","H","I","J","K","L","M","N","O","P","Q","R","S","U","V","W","X","Y","Z"]
        
        for letter in nonNucleotideLetters {
            if textField.text!.contains(letter) || textField.text!.containsNumbers() {
                textField.text = "Nucleotide sequence not recognized"
                textField2.text = ""
                labelTranslated.text = ""
                countLabel1.text = "0"
                countLabel2.text = "0"
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
        
        
        textFieldShouldReturn(textField)
        
        
        
        
    }
    

    @IBAction func translateButton(_ sender: Any) {

        if isAction == true {
            originalString = textField2.text!
            isAction = true
            labelTranslated.text = ""
        }
        

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
        
        // Letters that aren't G,C,A,U
        let nonNucleotideLetters = ["B","D","E","F","H","I","J","K","L","M","N","O","P","Q","R","S","T","W","X","Y","Z"]
        
        for letter in nonNucleotideLetters {
            if textField2.text!.contains(letter) || textField2.text!.containsNumbers() {
                textField2.text = "Nucleotide sequence not recognized"
                RNA = ""
                textField.text = ""
                labelTranslated.text = ""
                countLabel1.text = "0"
                countLabel2.text = "0"
                stepper.isHidden = true
                readingFrameValueLabel.isHidden = true
            }
        }
        
        
        for element in textField2.text! {
            numberOfCharacters += 1
            //print(numberOfCharacters)
            
            rnaSequenceDebug.append(String(element))
            checkRNA.append(String(element))
            
            if numberOfCharacters % 3 == 0 {
                
                rnaSequenceDebug.append("---")
                print(rnaSequenceDebug)
                
                for (codon,aminoAcid) in codonTable {
                    if checkRNA == codon {
                        RNA.append(aminoAcid)
                        RNA.append("-")
                        labelTranslated.text! = RNA
                        checkRNA.removeAll()
                        //                        singleLetterAminoAcidOutlet.isHidden = false
                       // print("TranslatedLabelCount: \(labelTranslated.text!.count)")
                    }
                    
                }
            }}
        

        
        // Return Keyboard
        textFieldShouldReturn(textField2)
        
        // Unhide Stepper and Label
        stepper.isHidden = false
        readingFrameValueLabel.isHidden = false
        
        // Update History Table View
        if stepper.value == 1 && textField2.text!.count > 2 {

            tableViewArray.append(labelTranslated.text!)
            tableViewArray = tableViewArray.filter { $0 != "" }
            
            
            historyArrayDNA.append(textField.text!)
            historyArrayDNA = historyArrayDNA.filter { $0 != "" }
            historyArrayDNA = historyArrayDNA.filter { $0 != "Nucleotide sequence not recognized" }

            historyArrayRNA.append(textField2.text!)
            historyArrayRNA = historyArrayRNA.filter { $0 != "" }
            historyArrayRNA = historyArrayRNA.filter { $0 != "Nucleotide sequence not recognized" }
            
            
            tableViewArray.removeDuplicates()
            historyArrayDNA.removeDuplicates()
            historyArrayRNA.removeDuplicates()
            
            print(tableViewArray)
            print(historyArrayDNA)
            print(historyArrayRNA)
            
            
            // Save Value
            defaults.set(tableViewArray, forKey: "historyAmino") //setObject
            defaults.set(historyArrayDNA, forKey: "historyDNA")
            defaults.set(historyArrayRNA, forKey: "historyRNA")
            defaults.synchronize()
            
            if tableViewArray.count == 0 {
                historyArrayDNA.removeAll()
                historyArrayRNA.removeAll()
            }
            
            if tableViewArray.count != historyArrayDNA.count {

                historyArrayDNA.removeLast()
                historyArrayRNA.removeLast()
            }
            
            tableView.reloadData()
        }
        
        
        let labelWithoutDashes = labelTranslated.text!.components(separatedBy: "-")
        collectionItems = labelWithoutDashes
        print(collectionItems)
        
        collectionView.reloadData()
        
        isSingleLetter = true
        countLabel2.text = "\(textField2.text!.count)"
        
        hideCollectionView()

    
    }

    
    func reverseTranslate() {
        // complementary mRNA transcription
        
        var reverseString = ""
        for i in textField2.text! {
            switch i {
            case "G":
                reverseString.append("G")
                textField.text = reverseString
            case "A":
                reverseString.append("A")
                textField.text = reverseString
            case "C":
                reverseString.append("C")
                textField.text = reverseString
            case "U":
                reverseString.append("T")
                textField.text = reverseString
            case "g":
                reverseString.append("g")
                textField.text = reverseString
            case "a":
                reverseString.append("a")
                textField.text = reverseString
            case "u":
                reverseString.append("t")
                textField.text = reverseString
            case "c":
                reverseString.append("c")
                textField.text = reverseString
            default:
                print("Reverse Translated")
            }
            
        }
        
        if textField2.text!.isEmpty {
            reverseString.removeAll()
            textField.text = reverseString
        }
        
        countLabel1.text = "\(textField.text!.count)"

        if textField2.text!.containsEmoji == true {
            textField2.text = "Since when were emojis part of DNA?"
            textField.text = ""
            labelTranslated.text = ""
            countLabel1.text = "0"
            countLabel2.text = "0"
        }
        // Letters that aren't G,C,A,T
        let nonNucleotideLetters = ["B","D","E","F","H","I","J","K","L","M","N","O","P","Q","R","S","T","V","W","X","Y","Z", " "]
        
        for letter in nonNucleotideLetters {
            if textField2.text!.contains(letter) || textField2.text!.containsNumbers() {
                textField2.text = "Nucleotide sequence not recognized"
                textField.text = ""
                labelTranslated.text = ""
                countLabel1.text = "0"
                countLabel2.text = "0"
            }
        }
        
        
    }
    
    func reverseTranscribe() {
        // complementary mRNA transcription
    
        var reverseString = ""
        for i in textField.text! {
            switch i {
            case "G":
                reverseString.append("G")
                textField2.text = reverseString
            case "A":
                reverseString.append("A")
                textField2.text = reverseString
            case "C":
                reverseString.append("C")
                textField2.text = reverseString
            case "T":
                reverseString.append("U")
                textField2.text = reverseString
            case "g":
                reverseString.append("g")
                textField2.text = reverseString
            case "a":
                reverseString.append("a")
                textField2.text = reverseString
            case "t":
                reverseString.append("u")
                textField2.text = reverseString
            case "c":
                reverseString.append("c")
                textField2.text = reverseString
            default:
                print("Reverse Transcribed")
            }
        }
        
        if textField.text!.isEmpty {
            reverseString.removeAll()
            textField2.text = reverseString
        }
        
//
        countLabel2.text = "\(textField.text!.count)"
        
        if textField.text!.containsEmoji == true {
            textField.text = "Since when were emojis part of DNA?"
            textField2.text = ""
            labelTranslated.text = ""
            countLabel1.text = "0"
            countLabel2.text = "0"
        }

        // Letters that aren't G,C,A,T
        let nonNucleotideLetters = ["B","D","E","F","H","I","J","K","L","M","N","O","P","Q","R","S","U","V","W","X","Y","Z", " "]
        
        for letter in nonNucleotideLetters {
            if textField.text!.contains(letter) || textField.text!.containsNumbers() {
                textField.text = "Nucleotide sequence not recognized"
                textField2.text = ""
                labelTranslated.text = ""
                countLabel1.text = "0"
                countLabel2.text = "0"
            }
        }
        
    }
    
    
    var numberOfTaps = 0
    
    
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
    
    @IBAction func menuAction(_ sender: Any) {
        
        
        dismissKeyboard()
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 15, width: 16, height: 30))
        iconView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "DNAStrandSolo")
        iconView.image = image
        
        
        if !menuIsVisible {
            
            if width == 896 {
                tableView.isHidden = false
            }
            /// iphone 10 size fix
            if width < 800 {
                leadingC.constant = width * 0.5
                trailingC.constant = width * -0.5
            } else {
                leadingC.constant = width * 0.45
                trailingC.constant = width * -0.45
            }
            
            countLabel1.isHidden = true
            countLabel2.isHidden = true
//            navTitle.isHidden = false
            menuIsVisible = true
            print(tableViewArray.count)

            iconView.isHidden = true
            navigationItem.titleView = iconView
            
            var fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)

            
            if UIDevice.current.iPhoneX {
                fixedSpace.width = width * 0.35
            } else {
                fixedSpace.width = width * 0.37
            }

            navigationItem.leftBarButtonItems = [menuButton, fixedSpace, editButtonItem]
            
        } else {
            if width == 896 {
            tableView.isHidden = true
            }
            leadingC.constant = 0
            trailingC.constant = 0
            countLabel1.isHidden = false
            countLabel2.isHidden = false
//            navTitle.isHidden = true
            menuIsVisible = false
            
            navigationItem.titleView = iconView
            navigationItem.leftBarButtonItems = [menuButton]
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("animation is complete")
        }
        
    }
    
    
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            self.menuAction((Any).self)
            
            if width == 896 {
                tableView.isHidden = false
            }
            
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            if menuIsVisible == true {
                self.menuAction((Any).self)
                
                if width == 896 {
                    tableView.isHidden = true
                }
                
            }
            
            
            
            
        }
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewArray.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellReuseIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        tableView.backgroundView?.addSubview(blurEffectView)
        
        // set the text from the data model
        
        print(tableViewArray)

    
        cell.textLabel?.text = tableViewArray[indexPath.row]
    
        
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
    
        labelTranslated.text = tableViewArray[indexPath.row]
        textField.text = historyArrayDNA[indexPath.row]
        textField2.text = historyArrayRNA[indexPath.row]
        
        countLabel1.text = "\(textField.text!.count)"
        countLabel2.text = "\(textField2.text!.count)"
        textField.reloadInputViews()
        textField2.reloadInputViews()
        
        stepper.isHidden = false
        readingFrameValueLabel.isHidden = false
        originalString = textField2.text!
        stepper.value = 1
        readingFrameValueLabel.text = "reading frame: \(Int(stepper.value))"
        
        translateButton(self.translateButtonOutlet)
        
        handleGesture(gesture: UISwipeGestureRecognizer.init())
    
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Toggles the edit button state
        super.setEditing(editing, animated: animated)
        // Toggles the actual editing actions appearing on a table view
        tableView.setEditing(editing, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
//
            if  tableViewArray.count == historyArrayRNA.count & historyArrayDNA.count {
                tableViewArray.remove(at: indexPath.row)
                historyArrayDNA.remove(at: indexPath.row)
                historyArrayRNA.remove(at: indexPath.row)
            } else {
                tableViewArray.removeAll()
                historyArrayDNA.removeAll()
                historyArrayRNA.removeAll()
            }
//            tableViewArray.removeAll()
//            historyArrayRNA.removeAll()
//            historyArrayDNA.removeAll()

           
            if tableViewArray.isEmpty {
                historyArrayDNA.removeAll()
                historyArrayRNA.removeAll()
            }
            
            print(tableViewArray)
            print(historyArrayDNA)
            print(historyArrayRNA)
            
            collectionItems.removeAll()
            collectionView.isHidden = true
            textField.text = ""
            textField2.text = ""
            labelTranslated.text = ""
            originalString  = ""
            countLabel1.text = "0"
            countLabel2.text = "0"
            stepper.value = 1
            readingFrameValueLabel.isHidden = true
            stepper.isHidden = true
            defaults.set(tableViewArray, forKey: "historyAmino")
            defaults.set(historyArrayDNA, forKey: "historyDNA")
            defaults.set(historyArrayRNA, forKey: "historyRNA")
            defaults.synchronize()
        
            tableView.reloadData()
        }
        
    }
    
    @IBAction func stepperRFValueChanged(_ sender: UIStepper) {
        
        isAction = false
        let index = Int(sender.value)
        readingFrameValueLabel.text = "reading frame: \(Int(sender.value))"
        
        let strIndex = originalString.index(originalString.startIndex, offsetBy: index-1)
        let strI = originalString.suffix(from: strIndex)
        let newString = String(originalString.suffix(from: strIndex))
        
        textField2.text = newString
            
        translateButton(self.translateButtonOutlet)
        hideCollectionView()
    
        print("Stepper Value: \(stepper.value)")
//        reverseTranslate()
    
    
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath as IndexPath) as! CollectionViewCell
        //        cell.backgroundColor = UIColor.blue
        
   
        
        cell.singleLetterButton.setTitle(collectionItems[indexPath.item], for: .normal)
        //print(collectionItems[indexPath.item])
        
        var pink = UIColor(hexString: "#E91E63")
        var green = UIColor(hexString: "#00C853")
        
        if collectionItems[indexPath.item] == "Stop" {
            cell.backgroundColor = .black
        } else if collectionItems[indexPath.item] == "Met" || collectionItems[indexPath.item] == "M"  {
            cell.backgroundColor = green
        }
        else {
            cell.backgroundColor = pink
        }
        
        
        return cell
    }

    
    @IBAction func singleLetterAction(_ sender: Any) {
        
        hideCollectionView()
        
        if isSingleLetter == true {
            
            let aminoDictionary = ["G":"Gly", "A":"Ala", "L":"Leu", "M":"Met", "F":"Phe", "W":"Trp", "K":"Lys", "Q":"Gln", "E":"Glu", "S":"Ser", "P":"Pro", "V":"Val", "I":"Ile", "C":"Cys", "Y":"Tyr", "H":"His", "R":"Arg", "N":"Asn", "D":"Asp", "T":"Thr"]
            var aminoAcidString = ""
            var checkAmino = ""
            var numberOfLetters = 0
            
            let aminosWithoutDashes = labelTranslated.text!.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range:nil)
            
            for n in aminosWithoutDashes {
                numberOfLetters += 1
                checkAmino.append(n)
                
                if numberOfLetters % 3 == 0 {
                    
                    for (singleLetter, threeLetter) in aminoDictionary {
                        if checkAmino == threeLetter  {
                            aminoAcidString.append(singleLetter)
                            aminoAcidString.append("-")
                            
                            self.labelTranslated.text! = aminoAcidString
                            checkAmino.removeAll()
                        }
                        
                    }
                }
                
            }
            
            let labelWithoutDashes = self.labelTranslated.text!.components(separatedBy: "-")
            self.collectionItems = labelWithoutDashes
           // print(collectionItems)
            self.collectionView.reloadData()
            
            isSingleLetter = false
            
        }
        else {
            
            translateButton(self.translateButtonOutlet)
            hideCollectionView()
            
        }
        
    }
    
    func hideCollectionView() {
        
        if textField2.text!.count > 2 {
            
            collectionView.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.collectionView.isHidden = false
            }
            readingFrameValueLabel.isHidden = false
            stepper.isHidden = false
            
        } else {
            collectionView.isHidden = true
            readingFrameValueLabel.isHidden = true
            stepper.isHidden = true
            
        }
        
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_")
        return String(text.filter {okayChars.contains($0) })
    }
    

    func dnaKeyboard() {
        let customKeyboardView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: height * 0.3))
        textField.inputView = customKeyboardView
        customKeyboardView.backgroundColor = .white
        
        let blue = UIColor(hexString: "#2979FF")
        let red = UIColor(hexString: "#F44336")
        
        let buttonG = UIButton(type: .system)
        buttonG.frame = CGRect(x: width * 0.45, y: customKeyboardView.frame.size.height * 0.3, width: 65, height: 65)
        buttonG.backgroundColor = blue
        buttonG.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
        buttonG.setTitleColor(.white, for: .normal)
        buttonG.layer.cornerRadius = 5 
        buttonG.setTitle("G", for: .normal)
        buttonG.addTarget(self, action: #selector(GletterTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(buttonG)
        
        let buttonA = UIButton(type: .system)
        buttonA.frame = CGRect(x: width * 0.15, y: customKeyboardView.frame.size.height * 0.3, width: 65, height: 65)
        buttonA.backgroundColor = blue
        buttonA.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
        buttonA.setTitleColor(.white, for: .normal)
        buttonA.layer.cornerRadius = 5
        buttonA.setTitle("A", for: .normal)
        buttonA.addTarget(self, action: #selector(AletterTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(buttonA)
        
        let buttonC = UIButton(type: .system)
        buttonC.frame = CGRect(x: width * 0.6, y: customKeyboardView.frame.size.height * 0.3, width: 65, height: 65)
        buttonC.backgroundColor = blue
        buttonC.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
        buttonC.setTitleColor(.white, for: .normal)
        buttonC.layer.cornerRadius = 5
        buttonC.setTitle("C", for: .normal)
        buttonC.addTarget(self, action: #selector(CletterTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(buttonC)
        
        let buttonT = UIButton(type: .system)
        buttonT.frame = CGRect(x: width * 0.3, y: customKeyboardView.frame.size.height * 0.3, width: 65, height: 65)
        buttonT.backgroundColor = blue
        buttonT.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
        buttonT.setTitleColor(.white, for: .normal)
        buttonT.layer.cornerRadius = 5
        buttonT.setTitle("T", for: .normal)
        buttonT.addTarget(self, action: #selector(TletterTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(buttonT)
        
        let backspaceButton = UIButton(type: .custom)
        backspaceButton.backgroundColor = red
        backspaceButton.frame = CGRect(x: width * 0.75, y: customKeyboardView.frame.size.height * 0.3, width: 75, height: 65)
        backspaceButton.setImage(#imageLiteral(resourceName: "Backspace"), for: .normal)
        backspaceButton.layer.cornerRadius = 5
        backspaceButton.addTarget(self, action: #selector(backspaceTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(backspaceButton)
        
    }
    
    func rnaKeyboard() {
        let customKeyboardView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: height * 0.3))
        textField2.inputView = customKeyboardView
        customKeyboardView.backgroundColor = .white
        
        let blue = UIColor(hexString: "#2979FF")
        let red = UIColor(hexString: "#F44336")
        
        let buttonG = UIButton(type: .system)
        buttonG.frame = CGRect(x: width * 0.45, y: customKeyboardView.frame.size.height * 0.3, width: 65, height: 65)
        buttonG.backgroundColor = blue
        buttonG.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
        buttonG.setTitleColor(.white, for: .normal)
        buttonG.layer.cornerRadius = 5
        buttonG.setTitle("G", for: .normal)
        buttonG.addTarget(self, action: #selector(GletterTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(buttonG)
        
        let buttonA = UIButton(type: .system)
        buttonA.frame = CGRect(x: width * 0.15, y: customKeyboardView.frame.size.height * 0.3, width: 65, height: 65)
        buttonA.backgroundColor = blue
        buttonA.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
        buttonA.setTitleColor(.white, for: .normal)
        buttonA.layer.cornerRadius = 5
        buttonA.setTitle("A", for: .normal)
        buttonA.addTarget(self, action: #selector(AletterTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(buttonA)
        
        let buttonC = UIButton(type: .system)
        buttonC.frame = CGRect(x: width * 0.6, y: customKeyboardView.frame.size.height * 0.3, width: 65, height: 65)
        buttonC.backgroundColor = blue
        buttonC.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
        buttonC.setTitleColor(.white, for: .normal)
        buttonC.layer.cornerRadius = 5
        buttonC.setTitle("C", for: .normal)
        buttonC.addTarget(self, action: #selector(CletterTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(buttonC)
        
        let buttonU = UIButton(type: .system)
        buttonU.frame = CGRect(x: width * 0.3, y: customKeyboardView.frame.size.height * 0.3, width: 65, height: 65)
        buttonU.backgroundColor = blue
        buttonU.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
        buttonU.setTitleColor(.white, for: .normal)
        buttonU.layer.cornerRadius = 5
        buttonU.setTitle("U", for: .normal)
        buttonU.addTarget(self, action: #selector(UletterTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(buttonU)
        
        let backspaceButton = UIButton(type: .custom)
        backspaceButton.frame = CGRect(x: width * 0.75, y: customKeyboardView.frame.size.height * 0.3, width: 75, height: 65)
        backspaceButton.backgroundColor = red
        backspaceButton.setImage(#imageLiteral(resourceName: "Backspace"), for: .normal)
        backspaceButton.layer.cornerRadius = 5
        backspaceButton.addTarget(self, action: #selector(backspaceTapped), for: UIControlEvents.touchUpInside)
        customKeyboardView.addSubview(backspaceButton)
        
    }
    

    @objc func GletterTapped() {
    
        if textField.isEditing == true {
            textField.insertText("G")
        } else {
            textField2.insertText("G")
        }
        
        countLabel1.text = "\(textField.text!.count)"
        countLabel2.text = "\(textField2.text!.count)"



    }
    @objc func AletterTapped() {
       
    
        if textField.isEditing == true {
            textField.insertText("A")
        } else {
            textField2.insertText("A")
        }
        
        
        countLabel1.text = "\(textField.text!.count)"
        countLabel2.text = "\(textField2.text!.count)"


    }
    @objc func CletterTapped() {
        
        if textField.isEditing == true {
            textField.insertText("C")
        } else {
            textField2.insertText("C")
        }

        countLabel1.text = "\(textField.text!.count)"
        countLabel2.text = "\(textField2.text!.count)"
       

    }
    
    @objc func TletterTapped() {
        
        textField.insertText("T")
        
        countLabel1.text = "\(textField.text!.count)"
        countLabel2.text = "\(textField2.text!.count)"


    }
    
    @objc func UletterTapped() {
        
        
        textField2.insertText("U")
        
        countLabel1.text = "\(textField.text!.count)"
        countLabel2.text = "\(textField2.text!.count)"

    }
    
    @objc func backspaceTapped() {

        if textField.text!.count > 0 {
            
            textField.deleteBackward()
            textField2.deleteBackward()
            
        } else {
            print("No characters to backspace")
        }
            
        countLabel1.text = "\(textField.text!.count)"
        reverseTranscribe()
    
        
    }
    

    

}


extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}


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

extension String
{
    func containsNumbers() -> Bool
    {
        let numberRegEx  = ".*[0-9]+.*"
        let testCase     = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return testCase.evaluate(with: self)
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

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension String {
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
            0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
}



extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}
