//
//  ViewController+ARCoachingViewDelegate.swift
//  Room Planner
//
//  Created by Evan Kirkiles on 12/16/19.
//  Copyright © 2019 Evan Kirkiles. All rights reserved.
//

import UIKit
import ARKit

extension ViewController: ARCoachingOverlayViewDelegate {

    /// - Tag: HideUI
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        controlView.isHidden = true
    }
    
    /// - Tag: PresentUI
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        controlView.isHidden = false
        readyToBuild = true
    }
    
    /// - Tag: StartOver
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        restartExperience()
    }
    
    func setupCoachingOverlay() {
        // Set up the coaching view
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
        coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
        coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        setActivatesAutomatically()
        
        // Coach the user to find a horizontal plane.
        setGoal()
    }
    
    /// - Tag: CoachingActivatesAutomatically
    func setActivatesAutomatically() {
        coachingOverlay.activatesAutomatically = true
    }
    
    /// - Tag: CoachingGoal
    func setGoal() {
        coachingOverlay.goal = .horizontalPlane
    }
}
