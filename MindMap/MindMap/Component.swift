//
//  Component.swift
//  MindMap
//
//  Created by willsborKang on 2019/3/31.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class Composite: Component {
    let id: Int
    let description: String
    
    private var parent: Component?
    private var children: [Component] = []
    
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

class Root: Composite {
    override func addSibling(_ node: Component) {
        preconditionFailure()
    }
}

typealias Node = Composite


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
