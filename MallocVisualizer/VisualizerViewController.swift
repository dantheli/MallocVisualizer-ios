//
//  VisualizerViewController.swift
//  MallocVisualizer
//
//  Created by Daniel Li on 12/3/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class VisualizerViewController: UIViewController {
    
    var heapView: UIView!
    var blockViews: [UIView] = []
    var dragLabel: UILabel!
    var shapeLayers: [CAShapeLayer] = []
    
    @IBOutlet weak var addressContainer: UIView!
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var endAddressLabel: UILabel!
    
    var heap: UnsafeMutablePointer<UInt8>!
    var blocks: [Block] = []
    var heapSize: UInt32!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dragLabel = UILabel()
        dragLabel.text = "Drag finger across heap to see details"
        dragLabel.textColor = UIColor.darkGray
        dragLabel.font = UIFont.systemFont(ofSize: 14.0)
        dragLabel.sizeToFit()
        dragLabel.center = CGPoint(x: view.frame.width / 2, y: view.frame.height - 66.0)
        view.addSubview(dragLabel)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        render(heap: heap, heapSize: heapSize, blocks: blocks, size: size)
    }
    
    func render(heap: UnsafeMutablePointer<UInt8>, heapSize: UInt32, blocks: [Block], size: CGSize) {
        let pastViews = view.subviews.filter { $0 != addressContainer && $0 != dragLabel && ($0.isMember(of: UIView.self) || $0.isMember(of: UILabel.self)) }
        
        self.heap = heap
        self.blocks = blocks.reversed()
        self.blockViews = []
        self.heapSize = heapSize
        
        let margin: CGFloat = 44.0
        let heapWidth: CGFloat = size.width - 2 * margin
        let heapHeight: CGFloat = 44.0
        
        heapView = UIView(frame: CGRect(x: margin, y: size.height / 3, width: heapWidth, height: heapHeight))
        heapView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        heapView.alpha = 0.0
        view.addSubview(heapView)
        
        startAddressLabel.text = String(format: "%p", heap)
        endAddressLabel.text = String(format: "%p", heap.advanced(by: Int(heapSize)))
        
        if blocks.isEmpty {
            let label = UILabel()
            label.text = "Heap is empty!"
            label.font = UIFont.boldSystemFont(ofSize: 19.0)
            label.textColor = UIColor.gray
            label.sizeToFit()
            label.center = CGPoint(x: heapView.bounds.midX, y: heapView.bounds.midY)
            heapView.addSubview(label)
        }
        
        var totalSize: UInt32 = 0
        
        for block in self.blocks {
            let distance = heapWidth * CGFloat(heap.distance(to: block.pointer)) / CGFloat(heapSize)
            let blockView = UIView(frame: CGRect(x: CGFloat(distance), y: 0.0, width: heapWidth * CGFloat(block.size) / CGFloat(heapSize), height: heapHeight))
            blockView.backgroundColor = block.color
            heapView.addSubview(blockView)
            totalSize += block.size
            blockViews.append(blockView)
        }
        
        let sizeLabel = UILabel()
        sizeLabel.text = "\(heapSize) bytes (\(totalSize) allocated, \(heapSize - totalSize) unallocated)"
        sizeLabel.textColor = UIColor.gray
        sizeLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        sizeLabel.sizeToFit()
        sizeLabel.center = CGPoint(x: heapView.center.x, y: heapView.frame.maxY + 24.0)
        view.addSubview(sizeLabel)
        
        UIView.animate(withDuration: 0.35, animations: {
            pastViews.forEach { $0.alpha = 0.0 }
            self.heapView.alpha = 1.0
        }, completion: { Void in
            pastViews.forEach { $0.removeFromSuperview() }
        })
        
        dragLabel.center = CGPoint(x: size.width / 2, y: size.height - 66.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            handle(touch: touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            handle(touch: touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            handle(touch: touch, reset: true)
        }
    }
    
    func handle(touch: UITouch, reset: Bool = false) {
        let location = touch.location(in: heapView)
        shapeLayers.forEach { $0.removeFromSuperlayer() }
        shapeLayers.removeAll()
        UIView.animate(withDuration: 0.2) {
            for (index, blockView) in self.blockViews.enumerated() {
                if blockView.frame.contains(location) && !reset {
                    blockView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
                    blockView.alpha = 1.0
                    self.heapView.bringSubview(toFront: blockView)
                    self.highlightTableView(block: self.blocks[index], highlight: true)
                    
                    let path = UIBezierPath()
                    path.move(to: self.view.convert(blockView.frame.origin, from: self.heapView))
                    path.addLine(to: self.view.convert(CGPoint(x: self.startAddressLabel.center.x, y: self.startAddressLabel.frame.maxY), from: self.addressContainer))
                    
                    path.move(to: CGPoint(x: self.view.convert(blockView.frame.origin, from: self.heapView).x + blockView.frame.width, y: self.view.convert(blockView.frame.origin, from: self.heapView).y))
                    path.addLine(to: self.view.convert(CGPoint(x: self.endAddressLabel.center.x, y: self.endAddressLabel.frame.maxY), from: self.addressContainer))
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = path.cgPath
                    shapeLayer.strokeColor = self.blocks[index].color.cgColor
                    shapeLayer.lineWidth = 1.0
                    shapeLayer.fillColor = UIColor.clear.cgColor
                    self.view.layer.addSublayer(shapeLayer)
                    self.shapeLayers.append(shapeLayer)
                    
                    UIView.transition(with: self.view, duration: 0.2, options: [], animations: {
                        self.startAddressLabel.text = String(format: "%p", self.blocks[index].pointer)
                        self.startAddressLabel.textColor = self.blocks[index].color
                        self.endAddressLabel.text = String(format: "%p", self.blocks[index].pointer.advanced(by: Int(self.blocks[index].size)))
                        self.endAddressLabel.textColor = self.blocks[index].color
                    }, completion: nil)
                } else {
                    blockView.transform = reset ? CGAffineTransform.identity : CGAffineTransform(scaleX: 1.0, y: 0.7)
                    blockView.alpha = reset ? 1.0 : 0.5
                    self.highlightTableView(block: self.blocks[index], highlight: reset)
                    if reset {
                        UIView.transition(with: self.view, duration: 0.2, options: [], animations: {
                            self.startAddressLabel.text = String(format: "%p", self.heap)
                            self.startAddressLabel.textColor = UIColor.darkGray
                            self.endAddressLabel.text = String(format: "%p", self.heap.advanced(by: Int(self.heapSize)))
                            self.endAddressLabel.textColor = UIColor.darkGray
                        }, completion: nil)
                    }
                }
            }
        }
    }
    
    func highlightTableView(block: Block, highlight: Bool) {
        
        if let viewController = (splitViewController?.viewControllers.first as? UINavigationController)?.topViewController as? ViewController {
            let blocks: [Block] = self.blocks.reversed()
            if let blockIndex = blocks.index(where: { $0.pointer == block.pointer }) {
                let indexPath = IndexPath(row: blockIndex, section: 0)
                if let cell = viewController.tableView.cellForRow(at: indexPath) as? BlockCell {
                    UIView.transition(with: cell, duration: 0.2, options: [], animations: {
                        cell.fade(out: !highlight)
                    }, completion: nil)
                }
            }
        }
    }
}
