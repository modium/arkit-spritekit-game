//
//  Scene.swift
//  SpriteKitTest
//
//  Created by Jaf Crisologo on 2017-12-02.
//  Copyright © 2017 Jaf Crisologo. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    let ghostsLabel = SKLabelNode(text: "Ghosts")
    let numberOfGhostsLabel = SKLabelNode(text: "0")
    var creationTime:TimeInterval = 0
    var ghostCount = 0 {
        didSet {
            self.numberOfGhostsLabel.text = "\(ghostCount)"
        }
    }
    let killSound = SKAction.playSoundFileNamed("ghost", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        ghostsLabel.fontSize = 20
        ghostsLabel.fontName = "DevanagariSangamMN-Bold"
        ghostsLabel.color = .white
        ghostsLabel.position = CGPoint(x: 40, y: 50)
        addChild(ghostsLabel) // must be of type SKNode
        
        numberOfGhostsLabel.fontSize = 30
        numberOfGhostsLabel.fontName = "DevanagariSangamMN-Bold"
        numberOfGhostsLabel.color = .white
        numberOfGhostsLabel.position = CGPoint(x: 40, y: 10)
        addChild(numberOfGhostsLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if currentTime > creationTime {
            createGhostAnchor()
            creationTime = currentTime + TimeInterval(randomFloat(min: 3.0, max: 6.0))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let sceneView = self.view as? ARSKView else {
//            return
//        }
//
//        // Create anchor using the camera's current position
//        if let currentFrame = sceneView.session.currentFrame {
//
//            // Create a transform with a translation of 0.2 meters in front of the camera
//            var translation = matrix_identity_float4x4
//            translation.columns.3.z = -0.2
//            let transform = simd_mul(currentFrame.camera.transform, translation)
//
//            // Add a new anchor to the session
//            let anchor = ARAnchor(transform: transform)
//            sceneView.session.add(anchor: anchor)
//        }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let hit = nodes(at: location)
        if let node = hit.first {
            if node.name == "ghost" { // if what you touched is a ghost
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                
                let groupKillingActions = SKAction.group([fadeOut, killSound])
                let sequenceAction = SKAction.sequence([groupKillingActions, remove])
                
                node.run(sequenceAction)
                
                ghostCount -= 1
            }
        }
    }
    
    func createGhostAnchor() {
        guard let sceneView = self.view as? ARSKView else { return }
        
        let _360degrees = 2.0 * Float.pi
        // returns matrices describing a rotation transformation
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 1, 0, 0))
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 0, 1, 0))
        let rotation = simd_mul(rotateX, rotateY)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1 - randomFloat(min: 0.0, max: 1.0)
        
        let transform = simd_mul(rotation, translation)

        // create a new anchor
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
        
        ghostCount += 1
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}
