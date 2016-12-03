//
//  BlockCell.swift
//  MallocVisualizer
//
//  Created by Daniel Li on 12/3/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class BlockCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var block: Block!
    
    func setup(block: Block) {
        self.block = block
        textLabel?.text = "\(block.size) bytes"
        textLabel?.textColor = block.color
        detailTextLabel?.text = String(format:"%p", block.pointer)
        detailTextLabel?.textColor = UIColor.gray
    }
    
    func fade(out: Bool) {
        contentView.backgroundColor = out ? UIColor(white: 0.95, alpha: 1.0) : UIColor.white
        textLabel?.textColor = out ? UIColor.gray : block.color
        detailTextLabel?.textColor = out ? UIColor.lightGray : UIColor.gray
    }

}
