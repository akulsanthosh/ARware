//
//  ViewController.swift
//  Image Recognition
//
//  Created by Akul Santhosh on 7/28/18.
//  Copyright © 2018 Akul Santhosh. All rights reserved.
//
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    
    let fadeDuration: TimeInterval = 0.3
    let waitDuration: TimeInterval = 60
    
    lazy var fadeAction: SCNAction = {
        return .sequence([
            .fadeIn(duration: fadeDuration),
            .wait(duration: waitDuration),
            .fadeOut(duration: fadeDuration)
            ])
    }()
    
    
    lazy var treeNode: SCNNode = {
        guard let scene = SCNScene(named: "tree.scn"),
            let node = scene.rootNode.childNode(withName: "tree", recursively: false) else { return SCNNode() }
        let scaleFactor = 0.005
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = -.pi / 2
        return node
    }()
    
    lazy var bookNode: SCNNode = {
//        guard let scene = SCNScene(named: "book.scn"),
//            let node = scene.rootNode.childNode(withName: "book", recursively: false) else { return SCNNode() }
//        let scaleFactor  = 0.1
//        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
//        return node
        
        
        let cylinder = SCNTube(innerRadius: 0, outerRadius: 2.5, height: 8)
        
        let node = SCNNode(geometry: cylinder)
        let scaleFactor  = 1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x += -.pi / 2
        
        return node
    }()
    
    lazy var mountainNode: SCNNode = {
        guard let scene = SCNScene(named: "mountain.scn"),
            let node = scene.rootNode.childNode(withName: "mountain", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.25
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x += -.pi / 2
        return node
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        configureLighting()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @IBAction func resetButtonDidTouch(_ sender: UIBarButtonItem) {
        resetTrackingConfiguration()
    }
    
    func resetTrackingConfiguration() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
        label.text = "Move camera around to detect images"
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            guard let imageAnchor = anchor as? ARImageAnchor,
                let imageName = imageAnchor.referenceImage.name else { return }
            
            // TODO: Comment out code
            //            let planeNode = self.getPlaneNode(withReferenceImage: imageAnchor.referenceImage)
            //            planeNode.opacity = 0.0
            //            planeNode.eulerAngles.x = -.pi / 2
            //            planeNode.runAction(self.fadeAction)
            //            node.addChildNode(planeNode)
            
            // TODO: Overlay 3D Object
            let overlayNode = self.getNode(withImageName: imageName)
            overlayNode.opacity = 0
            overlayNode.position.x = 0
            overlayNode.position.y = 0
            overlayNode.position.z = 0
            overlayNode.runAction(self.fadeAction)
            print(overlayNode)
            node.addChildNode(overlayNode)
            self.label.text = "Image detected: \"\(imageName)\""
        }
    }
    
    func getPlaneNode(withReferenceImage image: ARReferenceImage) -> SCNNode {
        let plane = SCNPlane(width: image.physicalSize.width,
                             height: image.physicalSize.height)
        let node = SCNNode(geometry: plane)
        return node
    }
    
    func getNode(withImageName name: String) -> SCNNode {
        var node = SCNNode()
        switch name {
        case "Book":
            node = bookNode

        case "shoe4":
            node = bookNode
        default:
            break
        }
        return node
    }
    
}
