//
//  CommandManager.swift
//  MindMap
//
//  Created by willsborKang on 2019/4/22.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

protocol Command {
    func execute() throws
    func unexecute() throws
}

class CommandManager {
    
    private var redoCommands: [Command] = []
    private var undoCommands: [Command] = []
    
    var canUndo: Bool {
        return undoCommands.count > 0
    }
    
    var canRedo: Bool {
        return redoCommands.count > 0
    }
    
    func execute(_ command: Command) throws {
        try command.execute()
        undoCommands.append(command)
        redoCommands.removeAll()
    }
    
    func undo() throws {
        guard canUndo else { return }
        
        let command = undoCommands.removeLast()
        try command.unexecute()
        
        redoCommands.append(command)
    }
    
    func redo() throws {
        guard canRedo else { return }
        
        let command = redoCommands.removeLast()
        try command.execute()
        
        undoCommands.append(command)
    }
    
}
