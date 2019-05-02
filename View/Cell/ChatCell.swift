//
//  ChatCell.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/7.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit

class SenderCell: UITableViewCell {
    @IBOutlet weak var message: UILabel!
}

class ReceiverCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var message: UITextView!
}
