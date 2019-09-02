//
//  SpeechCell.swift
//  SpeachText
//
//  Created by Mahendra Vishwakarma on 02/09/19.
//  Copyright © 2019 Mahendra Vishwakarma. All rights reserved.
//

import UIKit

class SpeechCell: UITableViewCell {

    @IBOutlet weak var speechLebel: UILabel!
    @IBOutlet weak var speechDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(speech:Speech) {
        speechLebel.text = speech.speech
        speechDate.text = speech.createdDate
    }
    
}
