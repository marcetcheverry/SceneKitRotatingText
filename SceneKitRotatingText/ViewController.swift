//
//  ViewController.swift
//  SceneKitRotatingText
//
//  Created by Marc on 2/4/15.
//  Copyright (c) 2015 Marc. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func degreesToRadians (value:Double) -> CGFloat {
        return (CGFloat)(value * M_PI / 180.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up scene, floor, camera and lighting
        let scene = SCNScene()

        // Light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.5, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)

        // This will give us some nice shadows
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLightTypeOmni
        omniLightNode.light!.color = UIColor(white: 1, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 20, 0)
        scene.rootNode.addChildNode(omniLightNode)

        // Floor
        let floor = SCNFloor()

        // Set the material
        floor.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 109 / 255, blue: 0, alpha: 1)
        floor.reflectivity = 0.5
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        // You will need this so the text does not get clipped. Refer to documentation
        cameraNode.camera?.automaticallyAdjustsZRange = true

        // Position the camera off the floor vertically by 3 points, and place us away by 18 points
        cameraNode.position = SCNVector3Make(0, 3, 18)

        // Angle camera downward by -10 degrees
        cameraNode.rotation = SCNVector4Make((Float)(degreesToRadians(-10)), 0, 0, 0)

        // You could also achieve the same effect through a transform instead of setting values directly
//        let matrix: SCNMatrix4 = SCNMatrix4MakeTranslation(0, 3, 18)
        // Rotate the already translated matrix
//        cameraNode.transform = SCNMatrix4Rotate(matrix, (Float)(degreesToRadians(-10)), 1, 0, 0)

        scene.rootNode.addChildNode(cameraNode)

        // Set up text
        let text = SCNText(string: "Hello SceneKit!", extrusionDepth: 4)
        text.font = UIFont(name: "Zapfino", size: 10)

        // alignmentMode is currently broken on iOS, but works on the Mac. This is visible when doing multi line text. Refer to the documentation as to why containerFrame is needed.
//        text.containerFrame = CGRectMake(0, 0, 50, 50)
//        text.truncationMode = kCATruncationEnd
//        text.wrapped = true
//        text.alignmentMode = kCAAlignmentCenter

        let textNode = SCNNode(geometry: text)

        // Scale it to 20% on all axes
        textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        // Axes: (left/right, low/high, close/far)
        textNode.position = SCNVector3Make(0, 5, -15)

        // Smoother rendering, refer to documentation
        text.flatness = 0.1

        // We must pivot the text so that it is centered at 0.5, 0.5
        var minVec = SCNVector3Zero
        var maxVec = SCNVector3Zero
        if textNode.getBoundingBoxMin(&minVec, max: &maxVec) {
            let distance = SCNVector3(
                x: maxVec.x - minVec.x,
                y: maxVec.y - minVec.y,
                z: maxVec.z - minVec.z)

            textNode.pivot = SCNMatrix4MakeTranslation(distance.x / 2, distance.y / 2, distance.z / 2)
        }

        text.firstMaterial!.diffuse.contents = UIColor(red: 245/255, green: 216/255, blue: 0, alpha: 1)
        text.firstMaterial!.specular.contents = UIColor.whiteColor()

        scene.rootNode.addChildNode(textNode)

        self.sceneView.scene = scene

        // Animation sequence

        // Relative rotations on x and y axes
        var horizontalAction = SCNAction.rotateByAngle(degreesToRadians(-45), aroundAxis: SCNVector3Make(0, 1, 0), duration: 2)
        horizontalAction.timingMode = .EaseInEaseOut
        var reverseHorizontalAction = horizontalAction.reversedAction()

        var verticalAction = SCNAction.rotateByAngle(degreesToRadians(-45), aroundAxis: SCNVector3Make(1, 0, 0), duration: 2)
        verticalAction.timingMode = .EaseInEaseOut
        var reverseVerticalAction = verticalAction.reversedAction()

        // Create a sequence of animations
        var sequence = SCNAction.sequence([
            horizontalAction, // pan left
            reverseHorizontalAction, // center back
            reverseHorizontalAction, // pan right
            horizontalAction, // center back
            verticalAction, // pan down
            reverseVerticalAction, // center back
            reverseVerticalAction, // pan up
            verticalAction]) // center back

        // Make the sequence repeat forever
        sequence = SCNAction.repeatActionForever(sequence)
        textNode.runAction(sequence)
    }
}
