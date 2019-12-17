//
//  TextDisplay.swift
//  Room Planner
//
//  Created by Evan Kirkiles on 12/16/19.
//  Copyright © 2019 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit

// Creates a text display node with lookat constraint that auto-resizes
// based on the text within it.
class TextDisplay: SCNNode {
    
    // The component nodes of the text display
    private var background: SCNNode?
    private var textNode: SCNNode?
    
    // Build the text display object as an SCNPlane to look at the camera
    public init(text: String, color: UIColor, backgroundColor: UIColor = .clear) {
        
        super.init()
        
        let textGeom = SCNText(string: text, extrusionDepth: 0)
        textGeom.font = UIFont(name: "AvenirNext-Medium", size: 0.1)
        textGeom.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeom)
        // Bring it slightly forward on the z-axis
        textNode!.position = SCNVector3(0, 0, 0.01)
        center(node: textNode!)
        addChildNode(textNode!)
        
        // Add a background plane
        geometry = SCNPlane(width: 0.1, height: 0.05)
        geometry?.firstMaterial!.diffuse.contents = backgroundColor
        geometry?.firstMaterial?.transparency = 1
        
        let billboardconstraint = SCNBillboardConstraint()
        billboardconstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardconstraint]
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Centers the text display
    private func center(node: SCNNode) {
        let (min, max) = node.boundingBox
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        node.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
    
}
