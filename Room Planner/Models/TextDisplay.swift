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
    private var textGeom: SCNText?
    
    // Build the text display object as an SCNPlane to look at the camera
    public init(text: String, color: UIColor, backgroundColor: UIColor = .clear) {
        
        super.init()
        
        textGeom = SCNText(string: text, extrusionDepth: 0.0)
        textGeom!.firstMaterial?.writesToDepthBuffer = false
        textGeom!.firstMaterial?.diffuse.contents = UIColor.black
        textNode = SCNNode(geometry: textGeom)
        // Bring it slightly forward on the z-axis
        textNode!.position = SCNVector3(0, 0, 0.01)
        textNode!.scale = SCNVector3(0.001, 0.001, 0.001)
        center(node: textNode!)
        addChildNode(textNode!)
        
        // Add a background plane
        let bgnPlane = SCNPlane(width: 0.05, height: 0.03)
        bgnPlane.cornerRadius = 0.02
        geometry = bgnPlane
        geometry?.firstMaterial?.writesToDepthBuffer = false
        geometry?.firstMaterial?.diffuse.contents = UIColor.white
        
//        let billboardconstraint = SCNBillboardConstraint()
//        billboardconstraint.freeAxes = SCNBillboardAxis.Y
//        constraints = [billboardconstraint]
        renderingOrder = -100
    }
    
    // Changes the text displayed
    public func changeText(to: String) { textGeom!.string = to }
    
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
