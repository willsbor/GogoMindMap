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
    func returnResource(_ comp: Component)
    func requestResource(for comp: Component) throws
    
    func resetResource(_ comp: Component)
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
        case cantFindID(Int)
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
    
    func deleteMindMan() throws {
        if root == nil {
            throw Errors.rootNotExist
        }
        
        root = nil
    }
    
    @discardableResult
    func insertMode(_ desc: String, _ parentID: Int) throws -> Component {
        guard let parentNode = findNode(by: parentID, root) else {
            throw Errors.parentIDNotExist
        }
        
        let newNode = nodeMaker.createNode(desc)
        parentNode.addChild(newNode)
        return newNode
    }
    
    @discardableResult
    func deleteNode(for id: Int) throws -> Component {
        guard let node = findNode(by: id, root) else {
            throw Errors.cantFindID(id)
        }
        
        node.removeFromParent()
        nodeMaker.returnResource(node)
        
        return node
    }
    
    func appendNode(_ freedomNodes: Component, at parentID: Int) throws {
        guard let parentNode = findNode(by: parentID, root) else {
            throw Errors.parentIDNotExist
        }
        
        try nodeMaker.requestResource(for: freedomNodes)
        parentNode.addChild(freedomNodes)
    }
    
    func getNode(by id: Int) -> Component? {
        return findNode(by: id, root)
    }
    
    func saveMindMap(_ fileURL: URL) throws {
        guard let root = root else {
            throw Errors.rootNotExist
        }
        
        try nodeFileManager.save(root, to: fileURL)
    }
    
    func loadMindMap(_ fileURL: URL) throws {
        root = try nodeFileManager.load(from: fileURL)
        nodeMaker.resetResource(root!)
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
