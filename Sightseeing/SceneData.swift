//
//  SceneData.swift
//  Sightseeing
//
//  Created by Dominik Kura on 06.02.18.
//  Copyright © 2018 Dominik Kura & Aleksandar Mitkovski. All rights reserved.
//

import SceneKit

class SphereData{
    var sphereNode: SCNNode!
    var textNode: SCNNode!
    
    init(){
        sphereNode = createSphereNode()
        textNode = createTextNode()
    }
    
    func createSphereNode(rotationY:Float = 0.0, distance:Float = 0.0, radius:CGFloat = 1.0) -> SCNNode{
        print("SphereData. Created Spherenode")
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }
    
    func createTextNode(rotationY:Float = 0.0, distance:Float = 0.0, title:String = "title") -> SCNNode{
        print("SphereData. Created Textnode")
        let textBlock = SCNText(string: title, extrusionDepth: 0.5)
        textBlock.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textBlock)
        textNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        return textNode
    }
    
    func editSphereData(rotationY:Float, title:String = "title"){
        print("SphereData. Edited SphereData")
        // Translate first on -z direction
        let translation = SCNMatrix4MakeTranslation(0, 0, Float(-100))
        // Rotate (yaw) around y axis
        let rotation = SCNMatrix4MakeRotation(-1 * rotationY, 0, 1, 0)
        // Final transformation: TxR
        sphereNode.transform = SCNMatrix4Mult(translation, rotation)
        textNode.transform = SCNMatrix4Mult(translation, rotation)
    }
    
    func getSphereData() -> Bool{
        return true
    }
}
