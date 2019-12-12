//
//  Corner.swift
//  Room Planner
//
//  Created by Evan Kirkiles on 12/7/19.
//  Copyright © 2019 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit

// Class to centralize the geometries of all models added to the scene.
// Currently includes: corners
class Geometries: NSObject {
    
    // Geometry of the floor, especially its color / transparency
    static func Floor() -> SCNGeometry {
        let geom = SCNFloor()
        geom.firstMaterial!.transparency = 0
        return geom
    }

    // Geometry of a corner, at each vertex added to a room boundary.
    static func Corner() -> SCNGeometry {
        let geom = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.07)
        geom.firstMaterial?.diffuse.contents = UIColor.clear
        return geom
    }
}
