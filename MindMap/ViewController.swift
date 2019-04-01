//
//  ViewController.swift
//  MindMap
//
//  Created by willsborKang on 2019/3/21.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var contentView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView.wantsLayer = true
    }
    
    private func redrawNodes() {
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let root = MindMapModel.shared.root else {
            return
        }
        
        redrawNodes(from: root, level: 0, y_level: 0)
    }
    
    private func redrawNodes(from node: Component, level: Int, y_level: Int) {
        
        let x = 10 + level * 100
        let y = 50 + y_level * 70
        let w = 60
        let h = 30
        drawNode(NSRect(x: x, y: y, width: w, height: h), textDesc: "\(node.id): \(node.description)")
        
        let children = node.getChildren()
        for i in 0..<children.count {
            let com = children[i]
            redrawNodes(from: com, level: level + 1, y_level: y_level + i)
        }
    }
    
    private func drawNode(_ frame: NSRect, textDesc: String) {
        let nodeView = NSView(frame: frame)
        nodeView.wantsLayer = true
        nodeView.layer?.backgroundColor = NSColor.lightGray.cgColor
        contentView.addSubview(nodeView)
        
        let text = NSTextField(wrappingLabelWithString: textDesc)
        text.wantsLayer = true
        text.frame = frame
        contentView.addSubview(text)
    }
    
    @objc
    func createMindMap() {
        let (msg, txt) = inputAlert("input Description", "input Description for Root", "Root")
        
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == .alertFirstButtonReturn) {
            print("\(txt.stringValue)")
            try! MindMapModel.shared.createMindMap(txt.stringValue)
            
            redrawNodes()
        } else {
            print("no value")
        }
    }
    
    @objc
    func insertNode() {
        var (msg, txt) = inputAlert("input Parent Node Id", "Integer!!", "0")
        var response: NSApplication.ModalResponse = msg.runModal()
        guard response == .alertFirstButtonReturn else {
            print("no value")
            return
        }
        let parentID: Int = txt.integerValue
        
        (msg, txt) = inputAlert("input Description", "input Description for Root", "")
        response = msg.runModal()
        guard response == .alertFirstButtonReturn else {
            print("no value")
            return
        }
        
        let desc = txt.stringValue
        
        try! MindMapModel.shared.insertMode(desc, parentID)
        
        redrawNodes()
    }
    
    private func inputAlert(_ title: String, _ information: String, _ defaultSring: String) -> (NSAlert, NSTextField) {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = title
        msg.informativeText = information
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = defaultSring
        
        msg.accessoryView = txt
        
        return (msg, txt)
    }

//    override var representedObject: Any? {
//        didSet {
//            let nodeView = NSView(frame: NSRect(x: 100, y: 10, width: 50, height: 25))
//            nodeView.layer?.backgroundColor = NSColor.blue.cgColor
//
//            self.contentView.addSubview(nodeView)
//        }
//    }


}
