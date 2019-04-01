//
//  AppDelegate.swift
//  MindMap
//
//  Created by willsborKang on 2019/3/21.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let nodeMaker = CompositeNodeMaker()
        let nodeIDProvider = NodeIDProvider()
        nodeMaker.nodeIDProvider = nodeIDProvider
        MindMapModel.shared.nodeMaker = nodeMaker  ///< TODO: Consider Load MindMap
        
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
        
        mainMenu.addItem(mainAppMenuItem)
        mainMenu.addItem(mainFileMenuItem)
        mainMenu.addItem(mainNodeMenuItem)
        
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
        fileMenu.addItem(withTitle: "New MindMap", action: #selector(ViewController.createMindMap), keyEquivalent: "n")
        
        let nodeMenu = NSMenu(title: "Node")
        mainNodeMenuItem.submenu = nodeMenu
        nodeMenu.addItem(withTitle: "insert a Node", action: #selector(ViewController.insertNode), keyEquivalent: "i")
        
        return mainMenu
    }

}

