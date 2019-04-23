//
//  Component.swift
//  MindMap
//
//  Created by willsborKang on 2019/3/31.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class Component: Codable {
    let id: Int
    var description: String
    
    private(set) var parent: Component?
    private var children: [Component] = []
    
    enum CodingKeys: CodingKey {
        case id
        case description
        case parent
        case children
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.description = try container.decode(String.self, forKey: .description)
//        self.parent = try container.decodeIfPresent(Component.self, forKey: .parent)
        self.children = try container.decode([Component].self, forKey: .children)
        self.children.forEach { (comp) in
            comp.parent = self
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(description, forKey: .description)
//        try container.encodeIfPresent(parent, forKey: .parent)
        try container.encode(children, forKey: .children)
    }
    
    init(id: Int, description: String) {
        self.id = id
        self.description = description
    }
    
    func addChild(_ node: Component) {
        children.append(node)
        node.parent = self
    }
    
    func removeChild(_ node: Component) {
        children.removeAll { $0 == node }
        node.parent = nil
    }
    
    func removeFromParent() {
        parent?.removeChild(self)
    }
    
    func addSibling(_ node: Component) {
        parent?.addChild(node)
    }
    
    func getChildren() -> [Component] {
        return children
    }
}

extension Component: Equatable {
    static func == (lhs: Component, rhs: Component) -> Bool {
        return lhs.id == rhs.id
    }
}

class Root: Component {
    override func addSibling(_ node: Component) {
        preconditionFailure()
    }
}

typealias Node = Component

protocol NodeIDProviding {
    func nextID() -> Int
    func retainFreeID(_ freeID: Int)
    func requestSpecificID(_ specificIDs: [Int]) throws
    func resetCurrentIDs(by ids: [Int])
}

class CompositeNodeMaker: NodeMaker {
    var nodeIDProvider: NodeIDProviding!
    
    func createNode(_ desc: String) -> Component {
        return Node(id: nodeIDProvider.nextID(), description: desc)
    }
    
    func returnResource(_ comp: Component) {
        nodeIDProvider.retainFreeID(comp.id)
        for c in comp.getChildren() {
            returnResource(c)
        }
    }
    
    func requestResource(for comp: Component) throws {
        let ids = getAllIDs(comp)
        try nodeIDProvider.requestSpecificID(ids)
    }
    
    func resetResource(_ comp: Component) {
        let ids = getAllIDs(comp)
        nodeIDProvider.resetCurrentIDs(by: ids)
    }
    
    private func getAllIDs(_ comp: Component) -> [Int] {
        var result = [comp.id]
        for c in comp.getChildren() {
            result.append(contentsOf: getAllIDs(c))
        }
        return result
    }
}

class NodeIDProvider: NodeIDProviding {
    
    enum Errors: Error {
        case canNotAcceptSpecificIDs
    }
    
    private var currentMaxID = 0
    private var freeIDs: [Int] = []
    
    func resetCurrentIDs(by ids: [Int]) {
        var ids = ids
        ids.sort()
        currentMaxID = ids.last ?? 0
        for i in 1...currentMaxID {
            if !ids.contains(i) {
                freeIDs.append(i)
            }
        }
    }
    
    func retainFreeID(_ freeID: Int) {
        freeIDs.append(freeID)
        freeIDs.sort()
    }
    
    func requestSpecificID(_ specificIDs: [Int]) throws {
        var newFreeIDs = freeIDs
        
        let check = specificIDs.reduce(true) { (last, id) -> Bool in
            if last == false {
                return false
            }
            
            if newFreeIDs.contains(id) {
                newFreeIDs.removeAll(where: {$0 == id})
                return true
            } else if currentMaxID < id {
                if id - 1 >= currentMaxID + 1 {
                    for i in (currentMaxID + 1)...(id - 1) {
                        newFreeIDs.append(i)
                    }
                }
                currentMaxID = id
                
                return true
            } else {
                return false
            }
        }
        
        if check {
            freeIDs = newFreeIDs
        } else {
            throw Errors.canNotAcceptSpecificIDs
        }
    }
    
    func nextID() -> Int {
        if !freeIDs.isEmpty {
            return freeIDs.removeFirst()
        }
        
        currentMaxID = currentMaxID + 1
        return currentMaxID
    }
    
    private func getMaxID(_ component: Component?) -> Int {
        guard let component = component else {
            return 0
        }
        
        return component.getChildren().reduce(component.id) { (maxID, com) -> Int in
            let childMaxID = getMaxID(com)
            return childMaxID > maxID ? childMaxID : maxID
        }
    }
}

class CompositeNodeSaver: NodeFileManager {
    func load(from fileURL: URL) throws -> Component {
        let decoder = JSONDecoder()
        
        let data = try Data(contentsOf: fileURL)
        
        return try decoder.decode(Component.self, from: data)
    }
    
    func save(_ node: Component, to fileURL: URL) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(node)
        
        try data.write(to: fileURL)
    }
}
