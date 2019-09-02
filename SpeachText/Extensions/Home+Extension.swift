//
//  Home+Extension.swift
//  SpeachText
//
//  Created by Mahendra Vishwakarma on 01/09/19.
//  Copyright © 2019 Mahendra Vishwakarma. All rights reserved.
//

import Foundation
import Speech
import UIKit

extension Home {
    func initialization() {
        
        speechRecognizer.delegate = self
        askForPermission()
        tableview.register(UINib(nibName: "SpeechCell", bundle: nil), forCellReuseIdentifier: "speechCell")
        tableview.tableFooterView = UIView(frame: .zero)
    }
    
    func addRecordedSpeech() {
        let speech = Speech()
        speech.speech = txtField.text ?? ""
        speech.createdDate = Utils.setDateFormat(date: Date())
        speech.sID = "\(arc4random_uniform(1000000))"
        
        do{
            try Utils.realm.write {
                Utils.realm.add(speech)
            }
        }catch let error
        {print(error)}
    }
    
    func askForPermission() {
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
           var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            @unknown default:
                print("\(authStatus)")
                break
                
            }
            
            OperationQueue.main.addOperation() {
                 self.microphoneButton.isEnabled = isButtonEnabled
                 self.headingLabel.text = isButtonEnabled ? "Listing..." : "Permission not granted"
            }
        }
    }
    
    func startedListing() {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setImage(UIImage(named: "mice"), for: .normal)
            headingLabel.text = "Paused..."
           
        } else {
            startRecording()
            microphoneButton.setImage(UIImage(named: "micered"), for: .normal)
            headingLabel.text = "Listing...."
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.voiceChat)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.txtField.text = result?.bestTranscription.formattedString
                self.filterSpeech(text: self.txtField.text ?? "")
                isFinal = (result?.isFinal)!
            }
            
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
               // self.headingLabel.text = "Listing..."
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
       
        
    }
    
}

extension Home:SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("is available:\(available)")
        if available {
            microphoneButton.isEnabled = true
            headingLabel.text = "Ready to listen"
        } else {
            microphoneButton.isEnabled = false
            headingLabel.text  = "Paused"
        }
    }
}


extension Home : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,with: string)
            filterSpeech(text: updatedText)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        microphoneButton.isEnabled = false
        microphoneButton.setImage(UIImage(named: "mice"), for: .normal)
        headingLabel.text = "Ready to listen..."
        return true
    }
    
    func filterSpeech(text:String) {
        let predicate = NSPredicate(format: "speech contains[c] %@", text)
        speechRecords = Utils.realm.objects(Speech.self).filter(predicate).sorted(byKeyPath: "createdDate", ascending: false)
        tableview.reloadData()
    }
}


extension Home : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speechRecords != nil ? speechRecords.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "speechCell", for: indexPath) as? SpeechCell else{
            return UITableViewCell()
        }
        
        cell.setData(speech: speechRecords[indexPath.row])
        return cell
    }
}
