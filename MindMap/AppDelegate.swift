//
//  AppDelegate.swift
//  MindMap
//
//  Created by willsborKang on 2019/3/21.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Cocoa

protocol MainDrawPaper {
    func redrawNodes()
}

var commandManager: CommandManager!
var mainDrawPaper: MainDrawPaper?

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        commandManager = CommandManager()
        
        let nodeMaker = CompositeNodeMaker()
        let nodeIDProvider = NodeIDProvider()
        let nodeFileManager = CompositeNodeSaver()
        nodeMaker.nodeIDProvider = nodeIDProvider
        MindMapModel.shared.nodeMaker = nodeMaker
        MindMapModel.shared.nodeFileManager = nodeFileManager
        
        NSApplication.shared.mainMenu = makeMainMenu()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func makeMainMenu() -> NSMenu {
        let mainMenu            = NSMenu() // `title` really doesn't matter.
        let mainAppMenuItem     = NSMenuItem(title: "Application", action: nil, keyEquivalent: "") // `title` really doesn't matter.
        let mainFileMenuItem    = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
        let mainNodeMenuItem    = NSMenuItem(title: "Node", action: nil, keyEquivalent: "")
        let mainActionMenuItem    = NSMenuItem(title: "Action", action: nil, keyEquivalent: "")
        
        mainMenu.addItem(mainAppMenuItem)
        mainMenu.addItem(mainFileMenuItem)
        mainMenu.addItem(mainNodeMenuItem)
        mainMenu.addItem(mainActionMenuItem)
        
        let appMenu             = NSMenu() // `title` really doesn't matter.
        mainAppMenuItem.submenu = appMenu
        
        let appServicesMenu     = NSMenu()
        NSApp.servicesMenu      = appServicesMenu
        
        appMenu.addItem(withTitle: "About Me", action: nil, keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Preferences...", action: nil, keyEquivalent: ",")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Hide Me", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem({ () -> NSMenuItem in
            let m = NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
            m.keyEquivalentModifierMask = [.command, .option]
            return m
            }())
        appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Services", action: nil, keyEquivalent: "").submenu = appServicesMenu
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit Me", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        let fileMenu = NSMenu(title: "File")
        mainFileMenuItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "New MindMap", action: #selector(AppDelegate.createMindMap), keyEquivalent: "n")
        fileMenu.addItem(withTitle: "Save MindMap", action: #selector(AppDelegate.saveMindMap), keyEquivalent: "s")
        fileMenu.addItem(withTitle: "Load MindMap", action: #selector(AppDelegate.loadMindMap), keyEquivalent: "l")
        
        let nodeMenu = NSMenu(title: "Node")
        mainNodeMenuItem.submenu = nodeMenu
        nodeMenu.addItem(withTitle: "insert a Node", action: #selector(AppDelegate.insertNode), keyEquivalent: "i")
        nodeMenu.addItem(withTitle: "edit a Node", action: #selector(AppDelegate.editNode), keyEquivalent: "e")
        nodeMenu.addItem(withTitle: "delete a Node", action: #selector(AppDelegate.deleteNode), keyEquivalent: "d")
        
        let actionMenu = NSMenu(title: "Action")
        mainActionMenuItem.submenu = actionMenu
        actionMenu.addItem(withTitle: "Undo", action: #selector(AppDelegate.undo), keyEquivalent: "z")
        actionMenu.addItem(withTitle: "Redo", action: #selector(AppDelegate.redo), keyEquivalent: "")
        
        return mainMenu
    }

    @objc
    func createMindMap() {
        let (msg, txt) = inputAlert("input Description", "input Description for Root", "Root")
        
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == .alertFirstButtonReturn) {
            print("\(txt.stringValue)")
            do {
                try commandManager.execute(CreateMindMapCommand(metaDescription: txt.stringValue))
            } catch {
                errorAlert("create failed", "\(error)").runModal()
            }
            
            mainDrawPaper?.redrawNodes()
        } else {
            print("no value")
        }
    }
    
    @objc
    func insertNode() {
        var (msg, txt) = inputAlert("input Parent Node Id", "Integer!!", "")
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
        
        do {
            try commandManager.execute(InsertNodeCommand(metaDescription: desc, parentID: parentID))
        } catch {
            errorAlert("create failed", "\(error)").runModal()
        }
        
        mainDrawPaper?.redrawNodes()
    }
    
    @objc
    func editNode() {
        var (msg, txt) = inputAlert("input Target Node Id", "Integer!!", "")
        var response: NSApplication.ModalResponse = msg.runModal()
        guard response == .alertFirstButtonReturn else {
            print("no value")
            return
        }
        let targetID: Int = txt.integerValue
        
        guard let node = MindMapModel.shared.getNode(by: targetID) else {
            errorAlert("Warning", "Can not find id == \(targetID)").runModal()
            return
        }
        
        (msg, txt) = inputAlert("input New Description", "input Description for Root", node.description)
        response = msg.runModal()
        guard response == .alertFirstButtonReturn else {
            print("no value")
            return
        }
        
        let desc = txt.stringValue
        
        if desc == node.description {
            errorAlert("Warning", "Description is no changed").runModal()
            return
        }
        
        do {
            try commandManager.execute(EditNodeCommand(newMetaDescription: desc, targetID: targetID))
        } catch {
            errorAlert("create failed", "\(error)").runModal()
        }
        
        mainDrawPaper?.redrawNodes()
    }
    
    @objc
    func deleteNode() {
        let (msg, txt) = inputAlert("input Target Node Id", "Integer!!", "")
        let response: NSApplication.ModalResponse = msg.runModal()
        guard response == .alertFirstButtonReturn else {
            print("no value")
            return
        }
        let targetID: Int = txt.integerValue
        
        guard MindMapModel.shared.getNode(by: targetID) != nil else {
            errorAlert("Warning", "Can not find id == \(targetID)").runModal()
            return
        }
        
        do {
            try commandManager.execute(DeleteNodeCommand(targetID: targetID))
        } catch {
            errorAlert("create failed", "\(error)").runModal()
        }
        
        mainDrawPaper?.redrawNodes()
    }
    
    @objc
    func saveMindMap() {
        let panel = NSSavePanel(contentRect: NSRect(x: 0, y: 0, width: 200, height: 150), styleMask: [.closable, .resizable], backing: .buffered, defer: true)
        
        panel.allowedFileTypes = ["mindmap"]
        panel.nameFieldStringValue = "new-mind-map.mindmap"
        panel.canCreateDirectories = true
        
        panel.begin { (response) in
            if response == .OK {
                do {
                    if let url = panel.url {
                        try MindMapModel.shared.saveMindMap(url)
                    } else {
                        self.errorAlert("save mind map error", "url is nil").runModal()
                    }
                } catch {
                    self.errorAlert("save mind map error", "\(error)").runModal()
                }
            }
        }
    }
    
    @objc
    func loadMindMap() {
        let panel = NSOpenPanel(contentRect: NSRect(x: 0, y: 0, width: 200, height: 150), styleMask: [.closable, .resizable], backing: .buffered, defer: true)
        
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["mindmap"]
        
        panel.begin { (response) in
            guard response == .OK else { return }
            
            DispatchQueue.main.async {
                do {
                    if let url = panel.url {
                        try MindMapModel.shared.loadMindMap(url)
                        mainDrawPaper?.redrawNodes()
                    } else {
                        self.errorAlert("load mind map error", "url is nil").runModal()
                    }
                } catch {
                    self.errorAlert("load mind map error", "\(error)").runModal()
                }
            }
        }
    }
    
    @objc
    func undo() {
        do {
            try commandManager.undo()
        } catch {
            errorAlert("create failed", "\(error)").runModal()
        }
        mainDrawPaper?.redrawNodes()
    }
    
    @objc
    func redo() {
        do {
            try commandManager.redo()
        } catch {
            errorAlert("create failed", "\(error)").runModal()
        }
        mainDrawPaper?.redrawNodes()
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
    
    private func errorAlert(_ title: String, _ information: String) -> NSAlert {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.messageText = title
        msg.informativeText = information
        
        return msg
    }
}

class CreateMindMapCommand: Command {
    
    let metaDescription: String
    
    init(metaDescription: String) {
        self.metaDescription = metaDescription
    }
    
    func execute() throws {
        try MindMapModel.shared.createMindMap(metaDescription)
    }
    
    func unexecute() throws {
        try MindMapModel.shared.deleteMindMan()
    }
}

class InsertNodeCommand: Command {
    
    let metaDescription: String
    let parentID: Int
    var newNodeID: Int?
    
    init(metaDescription: String, parentID: Int) {
        self.metaDescription = metaDescription
        self.parentID = parentID
    }
    
    func execute() throws {
        let newNode = try MindMapModel.shared.insertMode(metaDescription, parentID)
        newNodeID = newNode.id
    }
    
    func unexecute() throws {
        if let newNodeID = newNodeID {
            try MindMapModel.shared.deleteNode(for: newNodeID)
        }
    }
}

class EditNodeCommand: Command {
    
    let newMetaDescription: String
    let targetID: Int
    private var oriDescription: String?
    
    init(newMetaDescription: String, targetID: Int) {
        self.newMetaDescription = newMetaDescription
        self.targetID = targetID
    }
    
    func execute() throws {
        guard let node = MindMapModel.shared.getNode(by: targetID) else {
            return
        }
        
        if oriDescription == nil {
            oriDescription = node.description
        }
        
        node.description = newMetaDescription
    }
    
    func unexecute() throws {
        guard let node = MindMapModel.shared.getNode(by: targetID) else {
            return
        }
        
        guard let oriDescription = oriDescription else {
            return
        }
        
        node.description = oriDescription
    }
    
}

class DeleteNodeCommand: Command {
    
    let targetID: Int
    
    private var parentID: Int?
    private var removedNodes: Component?
    
    init(targetID: Int) {
        self.targetID = targetID
    }
    
    func execute() throws {
        guard let node = MindMapModel.shared.getNode(by: targetID) else {
            return
        }
        
        if parentID == nil {
            parentID = node.parent?.id
        }
        if removedNodes == nil {
            removedNodes = try MindMapModel.shared.deleteNode(for: targetID)
        }
    }
    
    func unexecute() throws {
        guard let parentID = parentID else {
            return
        }
        
        guard let removedNodes = removedNodes else {
            return
        }
        
        try MindMapModel.shared.appendNode(removedNodes, at: parentID)
        self.parentID = nil
        self.removedNodes = nil
    }
    

}
