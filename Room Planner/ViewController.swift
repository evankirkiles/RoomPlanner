//
//  ViewController.swift
//  Room Planner
//
//  Created by Evan Kirkiles on 12/6/19.
//  Copyright © 2019 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Constants
    
    // How far away until snapping to initial point?
    final let SNAP_DISTANCE: Float = 0.05
    // Bit masks for objects
    final var FLOOR_BITMASK = 0x2
    
    // MARK: - FIELDS: Building Room

    // Has the ground level been found yet?
    var groundPlane: SCNNode?
    // The current projection onto the ground from the center
    var groundProjection: SCNNode?
    // Current room being built and the points associated with it
    var currentRoom: Room?
    var currentConnector: Connector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Create the tap recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        sceneView.addGestureRecognizer(tap)
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // Give the user their first instructions
        announce(message: "Please place your phone on the ground and tap the screen to initialize floor height!")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Handling Taps
    
    // Handles when the user performs a gesture on the screen
    @objc func handleTap(sender: UITapGestureRecognizer) {

        // If the first point has not been set, wait until user taps to set the point.
        if (groundPlane == nil) {
            
            // Build the floor and add it to the scene
            groundPlane = SCNNode(geometry: Geometries.Floor())
            groundPlane!.position.y = sceneView.pointOfView!.position.y - 0.1
            groundPlane?.categoryBitMask = FLOOR_BITMASK
            sceneView.scene.rootNode.addChildNode(groundPlane!)
            // Begin building the room
            currentRoom = Room(name: "Building room...")
            currentRoom!.position.y = groundPlane!.position.y
            sceneView.scene.rootNode.addChildNode(currentRoom!)
            
        } else {
            
            // MARK: - TAP: Building Room
            
            if (!currentRoom!.isCompleted()) {
                
                if (currentRoom!.addPoint(x: CGFloat(groundProjection!.worldPosition.x), z: CGFloat(groundProjection!.worldPosition.z))) {
                
                    currentConnector!.removeFromParentNode()
                    groundProjection?.removeFromParentNode()
                    groundProjection = nil
                    currentConnector = nil
                    
                } else {
                    if (currentConnector == nil) {
                        currentConnector = Connector(from: currentRoom!.getLastCorner()!, to: groundProjection!, type: .Building)
                        sceneView.scene.rootNode.addChildNode(currentConnector!)
                    }
                    currentConnector!.setFrom(node: currentRoom!.getLastCorner()!)
                }
                
            }

        }
        
    }
    
    // Change this once UI is built to display messages to screen
    func announce(message msg: String) {
        print(msg)
    }
    

    // MARK: - Rendering
    
    // The main render loop
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        // MARK: - RENDER: Building Room

        // If the room isn't yet finished, add the projection node to the coordinates found
        // by the hit test from the camera to the floor.
        if (groundPlane != nil && currentRoom != nil && !currentRoom!.isCompleted()) {
            let hitTestResult = sceneView.hitTest(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2), options: [SCNHitTestOption.categoryBitMask: FLOOR_BITMASK])
            if (!hitTestResult.isEmpty) {
                guard let hitResult = hitTestResult.first else { return }
                if (groundProjection == nil) {
                    groundProjection = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.005))
                    sceneView.scene.rootNode.addChildNode(groundProjection!)
                }
                
                // If the ground projection is within a specific radius of the initial room
                // creation point, snap to that point.
                let firstCorner = currentRoom?.getFirstCorner()
                if (firstCorner != nil && hitResult.worldCoordinates.distance(vector: firstCorner!.worldPosition) < SNAP_DISTANCE) {
                    groundProjection!.worldPosition = firstCorner!.worldPosition
                } else {
                    groundProjection!.worldPosition = hitResult.worldCoordinates
                }
                
                currentConnector?.refresh()
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension Collection where Index: Comparable {
    subscript(back i: Int) -> Iterator.Element {
        let backBy = i + 1
        return self[self.index(self.endIndex, offsetBy: -backBy)]
    }
}

