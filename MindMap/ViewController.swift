//
//  ViewController.swift
//  MindMap
//
//  Created by willsborKang on 2019/3/21.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, MainDrawPaper {

    @IBOutlet weak var contentView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView.wantsLayer = true
        
        mainDrawPaper = self
    }
    
    func redrawNodes() {
        
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
        nodeView.layer?.cornerRadius = 4.0
        contentView.addSubview(nodeView)
        
        let text = NSTextField(wrappingLabelWithString: textDesc)
        nodeView.addSubview(text)
        text.alignment = .center
        text.wantsLayer = true
        text.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints(
            [NSLayoutConstraint(item: nodeView, attribute: .centerX, relatedBy: .equal, toItem: text, attribute: .centerX, multiplier: 1.0, constant: 0.0),
             NSLayoutConstraint(item: nodeView, attribute: .centerY, relatedBy: .equal, toItem: text, attribute: .centerY, multiplier: 1.0, constant: 0.0)])
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
