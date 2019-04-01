//
//  MindMapModel.swift
//  MindMap
//
//  Created by willsborKang on 2019/3/29.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

//protocol Component: Codable {
//    var id: Int { get }
//    var description: String  { get }
//
//    func addChild(_ node: Component)
//    func addSibling(_ node: Component)
//    func getChildren() -> [Component]
//    //    func getMap() //< for What
//}

protocol NodeMaker {
    func createNode(_ desc: String) -> Component
}

protocol NodeFileManager {
    func save(_ node: Component, to fileURL: URL) throws
    func load(from fileURL: URL) throws -> Component
}

class MindMapModel {
    
    enum Errors: Error {
        case hasRoot
        case parentIDNotExist
        case rootNotExist
    }
    
    static let shared = MindMapModel()
    
    var nodeMaker: NodeMaker! = nil
    var nodeFileManager: NodeFileManager! = nil
    private(set) var root: Component?
    
    var selectedComponent: Component?
    
    func createMindMap(_ desc: String) throws {
        if root != nil {
            throw Errors.hasRoot
        }
        
        root = nodeMaker.createNode(desc)
    }
    
    func insertMode(_ desc: String, _ parentID: Int) throws {
        guard let parentNode = findNode(by: parentID, root) else {
            throw Errors.parentIDNotExist
        }
        
        let newNode = nodeMaker.createNode(desc)
        parentNode.addChild(newNode)
    }
    
    func saveMindMap(_ fileURL: URL) throws {
        guard let root = root else {
            throw Errors.rootNotExist
        }
        
        try nodeFileManager.save(root, to: fileURL)
    }
    
    private func findNode(by id: Int, _ node: Component?) -> Component? {
        guard let node = node else {
            return nil
        }
        
        if node.id == id {
            return node
        }
        
        if node.getChildren().count == 0 {
            return nil
        }
        
        return node.getChildren().reduce(nil) { (object, component) -> Component? in
            return object ?? findNode(by: id, component)
        }
    }
}
