//
//  ViewController.swift
//  SpeachText
//
//  Created by Mahendra Vishwakarma on 28/08/19.
//  Copyright © 2019 Mahendra Vishwakarma. All rights reserved.
//

import UIKit
import Speech
import RealmSwift

 class Home: UIViewController {

    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()

    
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var txtField: UITextField!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var headingLabel: UILabel!
    
    var speechRecords : Results<Speech>!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialization()
        startedListing()
    }

    @IBAction func btnSearch(_ sender: Any) {
        
        filterSpeech(text: txtField.text ?? "")
    }
    @IBAction func microphoneTapped(_ sender: AnyObject) {
       startedListing()
    }
   
    
}

