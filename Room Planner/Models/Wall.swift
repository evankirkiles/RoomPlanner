//
//  Wall.swift
//  Room Planner
//
//  Created by Evan Kirkiles on 12/16/19.
//  Copyright © 2019 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit

// The wall node that extends up from two points.
class Wall: SCNNode {
    
    // Default color of the wall
    static let DEFAULT_COLOR = UIColor.black
    static let DEFAULT_TRANSPARENCY: CGFloat = 0.8

    // Save references to the nodes being connected
    private(set) var node1: SCNNode
    private(set) var node2: SCNNode
    
    // The geometry of the wall
    private var plane: SCNPlane
    
    // Builds the wall between the points
    init(from node1: SCNNode, to node2: SCNNode, height: CGFloat, withAnimation: Bool = false) {
        self.node1 = node1
        self.node2 = node2
        plane = SCNPlane(width: CGFloat(node1.position.distance(vector: node2.position)), height: height)
        plane.firstMaterial?.diffuse.contents = Wall.DEFAULT_COLOR
        plane.firstMaterial?.transparency = Wall.DEFAULT_TRANSPARENCY
        super.init()
        geometry = plane
        position = (node1.position + node2.position) / 2
        position.y += Float(plane.height / 2)
        eulerAngles = SCNVector3(0, -atan2(node1.position.x - position.x, node2.position.z - position.z) - .pi * 0.5, 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
