//
//  SYCustomInputKeyboard.swift
//  DatianDigitalAgriculture
//
//  Created by bsy on 2019/12/11.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit

class SYCustomInputKeyboard: UIView {
    
    @IBOutlet var buttons: [UIButton]!
    var textField : UITextField!
    static func loadCustomInputKeyboard(textField:UITextField) {
        let keyboard = Bundle.main.loadNibNamed("SYCustomInputKeyboard", owner: nil, options: nil)?.last as! SYCustomInputKeyboard
        keyboard.textField = textField
        keyboard.textField.inputView = keyboard
        keyboard.textField.reloadInputViews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        for btn in buttons {
            let normalColor = UIImage.sy_imageWithColor(color: .white, size: CGSize(width: 1, height: 1))
            let highlightColor = UIImage.sy_imageWithColor(color: .lightGray, size: CGSize(width: 1, height: 1))
            btn.setBackgroundImage(normalColor, for: .normal)
            btn.setBackgroundImage(highlightColor, for: .highlighted)
        }
    }
    @IBAction func keyClick(_ sender: UIButton) {
        if (sender.tag == 100){
            self.textField.insertText(".")
        }else if (sender.tag == 200){
            self.textField.insertText("-")
        }else if (sender.tag == 300){
            self.textField.deleteBackward()
        }else if (sender.tag == 400){
            self.textField.resignFirstResponder()
        }else if (sender.tag < 100){
            let countStr = String(sender.tag)
            self.textField.insertText(countStr)
        }
    }
}
