//
//  GameViewController.swift
//  My3DGame
//
//  Created by Daria on 01.08.17.
//  Copyright © 2017 Daria. All rights reserved.
//


//simple 3d 
//when you touch "enemy"-pyramids background became red color

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var gameView : SCNView! //where place scene
    var gameScene : SCNScene!
    var cameraNode: SCNNode! // all elements(pyramids for ex)
    var targetCreationTime : TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initScene()
        initCamera()
        
    }
    
    func initView() {
        
        gameView = self.view as! SCNView
        gameView.allowsCameraControl = true // play around with a camera
        gameView.autoenablesDefaultLighting = true
        
        gameView.delegate = self
    }
    
    func initScene() {
        gameScene = SCNScene()
        gameView.scene = gameScene // add scene in view
        
        gameView.isPlaying = true //endless gaming
    }
    
    func initCamera() {
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10) //position of our camera in 3D
        
        gameScene.rootNode.addChildNode(cameraNode) //for more good view for us
    }
    // create ogjects of game
    func createTarget() {
        
        let geometryObject: SCNGeometry = SCNPyramid(width: 1, height: 1, length: 1)
        //random 2 colors pyramid
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.blue : UIColor.yellow
        
        geometryObject.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: geometryObject)
        //here physic can be applied to our pyramids
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        if randomColor == UIColor.yellow {
            geometryNode.name = "enemy"
        } else {
            geometryNode.name = "friend"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)
        
        let randomDirectionUnderForce: Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3(x: randomDirectionUnderForce, y: 15, z: 0)
        
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3Make(0.05, 0.05, 0.05), asImpulse: true)
    }
    // function of SCNSceneRendererDelegate
    // make a lot of objects
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            createTarget()
            targetCreationTime = time + 0.6
        }
        cleanNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: gameView) //hit witch object we are hit
        let hittest = gameView.hitTest(location, options: nil)
        
        if let hitObject = hittest.first {
             let node = hitObject.node
            if node.name == "friend" {
                self.gameView.backgroundColor = UIColor.black
            } else {
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.red
            }
            }
        
        
    }
    
    //we want not too many nodes on our scene
    func cleanNodes() {
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
