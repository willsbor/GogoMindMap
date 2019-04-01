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
    let description: String
    
    private var parent: Component?
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
        self.parent = try container.decodeIfPresent(Component.self, forKey: .parent)
        self.children = try container.decode([Component].self, forKey: .children)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(parent, forKey: .parent)
        try container.encode(children, forKey: .children)
    }
    
    init(id: Int, description: String) {
        self.id = id
        self.description = description
    }
    
    func addChild(_ node: Component) {
        children.append(node)
    }
    
    func addSibling(_ node: Component) {
        parent?.addChild(node)
    }
    
    func getChildren() -> [Component] {
        return children
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
}

class CompositeNodeMaker: NodeMaker {
    var nodeIDProvider: NodeIDProviding!
    
    func createNode(_ desc: String) -> Component {
        return Node(id: nodeIDProvider.nextID(), description: desc)
    }
}

class NodeIDProvider: NodeIDProviding {
    private var currentMaxID = 0
    
    func updateCurrentID(by component: Component?) {
        currentMaxID = getMaxID(component)
    }
    
    func nextID() -> Int {
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
