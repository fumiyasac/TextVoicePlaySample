//
//  VoicePatternCell.swift
//  enryo_message
//
//  Created by 酒井文也 on 2015/12/26.
//  Copyright © 2015年 just1factory. All rights reserved.
//

import UIKit

class VoicePatternCell: UITableViewCell {

    //ラベル要素
    @IBOutlet var voicePatternId: UILabel!
    @IBOutlet var voicePatternText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
