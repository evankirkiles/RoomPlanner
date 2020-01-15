//
//  Room.swift
//  Room Planner
//
//  Created by Evan Kirkiles on 12/6/19.
//  Copyright © 2019 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit

class Room: SCNNode {
    
    // MARK: Fields
    
    // The name of the room (under which it will be saved)
    private var title: String!
    // Keep a reference to the camera node which will be looked at by text
    private var cameraNode: SCNNode
    
    // The list of all points' offsets from the initial point in the room
    private var boundaries: Array<(x: CGFloat, z: CGFloat)> = []
    
    // Eventually, there will also be an array of all the furnitures in the room. Later.
    // private var furniture: Array<Furniture>
    
    // The corners, walls, and connectors of this room
    private var corners = Array<SCNNode>()
    private var connectors = Array<Connector>()
    private var walls = Array<Wall>()
    
    // MARK: Constructors
    
    // Initializes an unbuilt room
    init(name: String, cameraNode: SCNNode) {
        self.title = name
        self.cameraNode = cameraNode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    // Adds a point to the room boundary, connected to the last point added, and returning true if the room is completed
    public func addPoint(x: CGFloat, z: CGFloat) -> Bool {
        boundaries.append((x, z))
        // Add the corner node to the point at the given hit
        let corner = SCNNode(geometry: Geometries.Corner())
        addChildNode(corner)
        corner.worldPosition = SCNVector3(x, CGFloat(position.y), z)
        corners.append(corner)
        // Connect the corner to the previous point
        if (corners.count > 1) {
            let connector = Connector(from: corners[back: 1], to: corner, type: .Built, withDistance: true)
            addChildNode(connector)
            connector.refresh()
            connectors.append(connector)
            // If the room is completed, return true and build the walls
            if (isCompleted()) {
                buildWalls()
                return true;
            }
        }
        return false;
    }
    
    // Removes the last point added to the room
    public func removeLastPoint() {
        if (boundaries.count != 0) {
            // Remove the walls if already completed room
            if (isCompleted()) {
                removeWalls()
            }
            
            boundaries.removeLast()
            connectors.removeLast()
            corners.removeLast()
        }
    }
    
    // Builds the walls of the room
    private func buildWalls() {
        if (!isCompleted()) { return }
        for i in 0..<(boundaries.count - 1) {
            let wall = Wall(from: corners[i], to: corners[i+1], height: 1, withAnimation: true)
            addChildNode(wall)
            walls.append(wall)
        }
    }
    
    // Removes the walls of the room
    private func removeWalls() {
        for wall:SCNNode in walls {
            wall.removeFromParentNode()
        }
        walls.removeAll(keepingCapacity: false)
    }
    
    // MARK: Getters
    
    // Title, boundaries
    public func getTitle() -> String { return title }
    public func getBoundaries() -> Array<(x: CGFloat, z: CGFloat)> { return boundaries }
    public func getLastCorner() -> SCNNode? { return corners.last }
    public func getFirstCorner() -> SCNNode? { return corners.first }
    
    // Checks if the room has been completed (size > 2 and last point == first point)
    public func isCompleted() -> Bool {
        return
            boundaries.count > 2 &&
            boundaries.last?.x == boundaries.first?.x &&
            boundaries.last?.z == boundaries.first?.z
    }

    
}
