//
//  Connector.swift
//  Room Planner
//
//  Created by Evan Kirkiles on 12/8/19.
//  Copyright © 2019 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit

// Handles functions for drawing lines between objects
class Connector: SCNNode {
    
    // The radius of connector lines
    static let CYLINDER_RADIUS: CGFloat = 0.001
    // How many times to repeat the texture per meter
    static let TEXTURE_REPEAT: Float = 50
    
    // Connector type enums
    enum ConnectorType {
        case Building
        case Built
    }

    // The geometry of the line
    private(set) var cylinder: SCNCylinder?
    // Save the material to not recalculate it every time
    private var firstMaterialStore: SCNMaterial
    // Save references to the nodes being connected
    private(set) var node1: SCNNode
    private(set) var node2: SCNNode
    
    // The type of connector (how should it be drawn)
    private(set) var type: ConnectorType
    // Draw the distance represented by the connector?
    private(set) var withDistance: Bool
    private var distanceNode: TextDisplay?
    
    // Build with references to the nodes to be connected
    init(from node1: SCNNode, to node2: SCNNode, type: ConnectorType, withDistance: Bool = true) {
        self.node1 = node1
        self.node2 = node2
        self.type = type
        self.withDistance = withDistance
        // Initialize the material to add to the cylinder
        self.firstMaterialStore = SCNMaterial()
        if (type == .Building) {
            self.firstMaterialStore.diffuse.contents = UIImage(named: "art.scnassets/line.png")
            let rotation = SCNMatrix4MakeRotation(.pi / 2, 0, 0, 1)
            self.firstMaterialStore.diffuse.contentsTransform = SCNMatrix4Mult(rotation, self.firstMaterialStore.diffuse.contentsTransform)
        } else {
            self.firstMaterialStore.diffuse.contents = UIColor.white
        }
        self.firstMaterialStore.diffuse.wrapS = .repeat
        self.firstMaterialStore.diffuse.wrapT = .repeat
        self.firstMaterialStore.isDoubleSided = true
        super.init()
        
        if (withDistance) {
            distanceNode = TextDisplay(text: "...", color: UIColor.white)
            addChildNode(distanceNode!)
        }
    }
    
    // Redraw the cylinder between the two points
    func refresh() {
        let vector = node1.worldPosition - node2.worldPosition
        let height = vector.length()
        cylinder = SCNCylinder(radius: Connector.CYLINDER_RADIUS, height: CGFloat(height))
        cylinder!.firstMaterial! = self.firstMaterialStore
        cylinder!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4MakeScale(2 * Float(Connector.CYLINDER_RADIUS) * Connector.TEXTURE_REPEAT, height * Connector.TEXTURE_REPEAT, 1)
        geometry = cylinder
        worldPosition = (node1.worldPosition + node2.worldPosition) / 2
        eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
        
        // If building with distance, create the distance node
        if (withDistance) {
            refreshdistance()
        }
    }
    
    // Redraw the distance
    func refreshdistance() {
        distanceNode?.eulerAngles = SCNVector3(0, 0, Float.pi/2)
    }
    
    // Sets the first and second node of the connector
    func setFrom(node: SCNNode) { self.node1 = node }
    func setTo(node: SCNNode) { self.node2 = node }
    
    // MARK: - SCNNode
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
