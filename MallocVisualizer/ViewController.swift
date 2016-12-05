//
//  ViewController.swift
//  MallocVisualizer
//
//  Created by Daniel Li on 12/1/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var emptyLabel: UILabel!
    
    var blocks: [Block] = []
    var heap: [UInt8] = []
    var heapBufferPointer: UnsafePointer<UInt8>?
    
    var initialPrompted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Malloc Visualizer"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        emptyLabel = UILabel()
        emptyLabel.text = "Heap is empty!\nAllocate a block."
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        emptyLabel.numberOfLines = 2
        emptyLabel.sizeToFit()
        emptyLabel.center = tableView.center
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        
        splitViewController?.preferredDisplayMode = .allVisible
        splitViewController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !initialPrompted {
            promptInit()
            initialPrompted = true
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyLabel.center = tableView.center
    }
    
    func insertBlock(block: Block) {
        var blocksCopy = blocks
        blocksCopy.append(block)
        let mutableHeapBufferPointer = UnsafeMutablePointer<UInt8>(mutating: heapBufferPointer)
        blocksCopy.sort { $0.pointer.distance(to: mutableHeapBufferPointer!) < $1.pointer.distance(to: mutableHeapBufferPointer!) }
        if let index = blocksCopy.index(where: { $0.pointer == block.pointer }) {
            blocks.insert(block, at: index)
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            updateVisualization()
            emptyLabel.isHidden = true
        }
    }
    
    func deleteBlock(block: Block) {
        if let index = blocks.index(where: { $0.pointer == block.pointer }) {
            blocks.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            updateVisualization()
        }
    }
    
    func promptInit() {
        let alertController = UIAlertController(title: "Create New Heap", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Size (in bytes)"
            textField.keyboardType = .numberPad
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Create", style: .default) { void in
            if let textField = alertController.textFields?.first {
                if let byteCount = UInt32(textField.text ?? "") {
                    self.initHeap(size: byteCount)
                }
            }
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func initHeap(size: UInt32) {
        heap = [UInt8](repeating: 0, count: Int(size))
        let success = hl_init(&heap, size)
        if !Bool(NSNumber(value: success)) {
            let alertController = UIAlertController(title: "Uh-oh", message: "hl_init failed...", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Got it.", style: .default) { action in
                self.promptInit()
            })
            present(alertController, animated: true, completion: nil)
            return
        }
        
        self.blocks = []
        self.tableView.reloadData()
        self.updateVisualization()
        self.emptyLabel.isHidden = false
        
        heap.withUnsafeBufferPointer { buffer in
            navigationItem.prompt = String(format:"Heap created at address: %p", buffer.baseAddress!)
            self.heapBufferPointer = buffer.baseAddress
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
        promptInit()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        guard !heap.isEmpty else { return }
        
        let alertController = UIAlertController(title: "Create New Block", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Size (in bytes)"
            textField.keyboardType = .numberPad
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Allocate", style: .default) { void in
            if let textField = alertController.textFields?.first {
                if let byteCount = UInt32(textField.text ?? "") {
                    if let pointer = hl_alloc(&self.heap, byteCount) {
                        let intPointer = pointer.bindMemory(to: UInt8.self, capacity: Int(byteCount))
                        let block = Block(pointer: intPointer, size: byteCount, color: self.colors[self.colorIndex])
                        self.colorIndex = (self.colorIndex + 1) % self.colors.count
                        self.insertBlock(block: block)
                    } else {
                        let alertController = UIAlertController(title: "Uh-oh", message: "Could not create block", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Got it.", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func updateVisualization() {
        if let visualizerViewController = navigationController?.splitViewController?.viewControllers.last as? VisualizerViewController {
            heap.withUnsafeBufferPointer { buffer in
                let mutablePointer = UnsafeMutablePointer<UInt8>(mutating: buffer.baseAddress!)
                visualizerViewController.render(heap: mutablePointer, heapSize: UInt32(heap.count), blocks: blocks, size: visualizerViewController.view.frame.size)
            }
        }
    }
    
    let colors: [UIColor] = [
        UIColor(red:0.23, green:0.60, blue:0.85, alpha:1.00),
        UIColor(red:0.94, green:0.76, blue:0.19, alpha:1.00),
        UIColor(red:0.16, green:0.73, blue:0.61, alpha:1.00),
        UIColor(red:0.60, green:0.36, blue:0.71, alpha:1.00),
        UIColor(red:0.22, green:0.79, blue:0.45, alpha:1.00),
        UIColor(red:0.90, green:0.30, blue:0.26, alpha:1.00),
        UIColor(red:0.89, green:0.49, blue:0.19, alpha:1.00)
    ]
    
    var colorIndex = 0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let visualizerViewController = segue.destination as? VisualizerViewController {
            heap.withUnsafeBufferPointer { buffer in
                let mutablePointer = UnsafeMutablePointer<UInt8>(mutating: buffer.baseAddress!)
                visualizerViewController.render(heap: mutablePointer, heapSize: UInt32(heap.count), blocks: blocks, size: visualizerViewController.view.frame.size)
            }
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! BlockCell
        
        let block = blocks[indexPath.row]
        cell.setup(block: block)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if UIDevice.current.userInterfaceIdiom != .pad {
            if let visualizerViewController = storyboard?.instantiateViewController(withIdentifier: "VisualizerViewController") as? VisualizerViewController {
                heap.withUnsafeBufferPointer { buffer in
                    let mutablePointer = UnsafeMutablePointer<UInt8>(mutating: buffer.baseAddress!)
                    visualizerViewController.render(heap: mutablePointer, heapSize: UInt32(heap.count), blocks: blocks, size: visualizerViewController.view.frame.size)
                    showDetailViewController(visualizerViewController, sender: self)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let block = blocks[indexPath.row]
        let resizeAction = UITableViewRowAction(style: .default, title: "Resize") { action, indexPath in
            let alertController = UIAlertController(title: "Resize Block", message: String(format: "%p", block.pointer), preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Size (in bytes)"
                textField.keyboardType = .numberPad
                textField.text = "\(block.size)"
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Resize", style: .default) { void in
                if let textField = alertController.textFields?.first {
                    if let byteCount = UInt32(textField.text ?? "") {
                        if let pointer = hl_resize(&self.heap, block.pointer, byteCount) {
                            let intPointer = pointer.bindMemory(to: UInt8.self, capacity: Int(byteCount))
                            let newBlock = Block(pointer: intPointer, size: byteCount, color: block.color)
                            
                            self.tableView.beginUpdates()
                            self.deleteBlock(block: block)
                            self.insertBlock(block: newBlock)
                            self.tableView.endUpdates()
                        } else {
                            let alertController = UIAlertController(title: "Uh-oh", message: "Could not resize block", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Got it.", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            })
            self.present(alertController, animated: true, completion: nil)
        }
        resizeAction.backgroundColor = UIColor.lightGray
        
        let freeAction = UITableViewRowAction(style: .destructive, title: "Free") { action, indexPath in
            hl_release(&self.heap, self.blocks[indexPath.row].pointer)
            self.deleteBlock(block: self.blocks[indexPath.row])
        }
        
        return [freeAction, resizeAction]
    }
    
}

