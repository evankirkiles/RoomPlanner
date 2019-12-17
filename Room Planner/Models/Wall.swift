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
    static let ANIMATION_DURATION = 1.0

    // Save references to the nodes being connected
    private(set) var node1: SCNNode
    private(set) var node2: SCNNode
    
    // The geometry of the wall
    private var plane: SCNPlane
    private var height: CGFloat
    
    // Builds the wall between the points
    init(from node1: SCNNode, to node2: SCNNode, height: CGFloat, withAnimation: Bool = false) {
        self.node1 = node1
        self.node2 = node2
        self.height = height
        plane = SCNPlane(width: CGFloat(node1.position.distance(vector: node2.position)), height: height)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/gradient.png")
        plane.firstMaterial?.transparency = Wall.DEFAULT_TRANSPARENCY
        plane.firstMaterial?.isDoubleSided = true
        super.init()
        geometry = plane
        position = (node1.position + node2.position) / 2
        position.y += Float(plane.height / 2)
        eulerAngles = SCNVector3(0, -atan2(node1.position.x - position.x, node2.position.z - position.z) - .pi * 0.5, 0)
        // If chosen to animate, move the position and height of the wall up
        if (withAnimation) {
            plane.height = 0
            self.runAction(SCNAction.customAction(duration: Wall.ANIMATION_DURATION, action: { (_, elapsedTime) in
                self.plane.height = elapsedTime * self.height / CGFloat(Wall.ANIMATION_DURATION)
                self.position.y = Float(self.plane.height / 2)
                })
            )
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
