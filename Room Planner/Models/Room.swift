//
//  Room.swift
//  Room Planner
//
//  Created by Evan Kirkiles on 12/6/19.
//  Copyright © 2019 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit

class Room: NSObject {
    
    // MARK: Fields
    
    // The name of the room (under which it will be saved)
    private var title: String!
    
    // The list of all points' offsets from the initial point in the room
    private var boundaries: Array<(x: CGFloat, z: CGFloat)> = []
    
    // Eventually, there will also be an array of all the furnitures in the room. Later.
    // private var furniture: Array<Furniture>
    
    // MARK: Constructors
    
    // Initializes an unbuilt room
    init(name: String) {
        title = name
    }
    
    // MARK: Methods
    
    // Adds a point to the room boundary, connected to the last point added
    public func addPoint(x: CGFloat, z: CGFloat) {
        boundaries.append((x, z))
    }
    
    // Removes the last point added to the room
    public func removeLastPoint() {
        if (boundaries.count != 0) {
            boundaries.removeLast()
        }
    }
    
    // Checks if the room has been completed (size > 2 and last point == first point)
    public func isCompleted() -> Bool {
        return
            boundaries.count > 2 &&
            boundaries.last?.x == boundaries.first?.x &&
            boundaries.last?.z == boundaries.first?.z
    }

    // MARK: Getters
    
    // Title, boundaries
    public func getTitle() -> String { return title }
    public func getBoundaries() -> Array<(x: CGFloat, z: CGFloat)> { return boundaries }
    
}
