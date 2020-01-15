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
    
    @IBOutlet weak var controlView: Overlay!
    
    @IBOutlet weak var crosshairView: UIImageView!
    
    // MARK: - UI Elements
    
    let coachingOverlay = ARCoachingOverlayView()
    
    // MARK: - Settings
    
    var readyToBuild = false
    
    var restartAvailable = true
    
    // MARK: - Constants
    
    // How far away until snapping to initial point?
    final let SNAP_DISTANCE: Float = 0.05
    // Bit masks for objects
    final var FLOOR_BITMASK = 0x2
    final var ANCHOR_BITMASK = 0x3
    
    // MARK: - Fields

    // Keep track of all the anchors added so we can delete them.
    var anchors = Array<ARAnchor>()
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
        
        // Initialize the coaching (tells user what to do to get setup)
        setupCoachingOverlay()
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        // Create the tap recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        sceneView.addGestureRecognizer(tap)
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // Give the user their first instructions
        announce(message: "Please place your phone on the ground and tap the screen to initialize floor height!")
        // Also initialize the basic crosshair
        crosshairView.image = UIImage(named: "art.scnassets/crosshair1.png")?.withTintColor(.white)
        // Hide the controls and crosshair until floor setup
        controlView.isHidden = true
        crosshairView.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Handling Taps
    
    // Handles when the user performs a gesture on the screen
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        // If not ready to begin, don't
        if (!readyToBuild) { return }

        // If the first point has not been set, wait until user taps to set the point.
        if (groundPlane == nil) {
            
            // Get the hit test from the center of the screen to set the floor height
            let hitTestResult = sceneView.hitTest(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2), options: [SCNHitTestOption.categoryBitMask: ANCHOR_BITMASK])
            if (!hitTestResult.isEmpty) {
                guard let hitResult = hitTestResult.first else { return }
                
                // Build the floor and add it to the scene
                groundPlane = SCNNode(geometry: Geometries.Floor())
                groundPlane?.categoryBitMask = FLOOR_BITMASK
                sceneView.scene.rootNode.addChildNode(groundPlane!)
                groundPlane!.worldPosition.y = hitResult.worldCoordinates.y
                // Begin building the room
                currentRoom = Room(name: "Building room...", cameraNode: sceneView.pointOfView!)
                currentRoom!.position.y = groundPlane!.position.y
                sceneView.scene.rootNode.addChildNode(currentRoom!)
                
                // Clear all anchors / remove them from scene
                for anchor: ARAnchor in anchors { sceneView.session.remove(anchor: anchor) }
                
            }
            
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
    
    // MARK: - Restart Experience
    
    // Removes the current room and "resets," clearing all variables
    func restartExperience() {
        guard restartAvailable else { return }
        restartAvailable = false
        
        groundPlane?.removeFromParentNode()
        groundPlane = nil
        groundProjection?.removeFromParentNode()
        groundProjection = nil
        currentRoom?.removeFromParentNode()
        currentRoom = nil
        currentConnector?.removeFromParentNode()
        currentConnector = nil
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        // Disable restart for 5 seconds while session sets up
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.restartAvailable = true
            self.controlView.isHidden = false
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
    
    // MARK: - Renderer functions
    // Only used to detect initial floor plane
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        if (groundPlane != nil) { return }
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        anchors.append(planeAnchor)
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIImage(named: "art.scnassets/placefloor.png")
        plane.materials.first?.transparency = 0.8
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.categoryBitMask = ANCHOR_BITMASK
        
        // 6
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        if (groundPlane != nil) { return }
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
         
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
         
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
}

extension Collection where Index: Comparable {
    subscript(back i: Int) -> Iterator.Element {
        let backBy = i + 1
        return self[self.index(self.endIndex, offsetBy: -backBy)]
    }
}

