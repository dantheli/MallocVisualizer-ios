//
//  Block.swift
//  MallocVisualizer
//
//  Created by Daniel Li on 12/3/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

struct Block {
    
    var pointer: UnsafeMutablePointer<UInt8>
    
    /// In bytes
    var size: UInt32
    
    var color: UIColor
}
