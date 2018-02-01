//
//  ViewController.swift
//  Sightseeing
//
//  Created by Dominik Kura on 11.01.18.
//  Copyright © 2018 Dominik Kura & Aleksandar Mitkovski. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import MapKit

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate{

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelBearing: UILabel!
    var locationManager: CLLocationManager!
    var anchor: ARAnchor!
    var circleNode = SCNNode()
    var locData = LocationData()
    var firstTime: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Create cone (which acts as a dummy for the orientation arrow)
        let cone = SCNCone(topRadius: 0.000001, bottomRadius: 0.005, height: 0.01)
        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3Make(-0.005, -0.035, -0.2)
        sceneView.pointOfView?.addChildNode(coneNode)
 
        // Create circle node
        circleNode = createSphereNode(with: 1, color: .red)
        //circleNode.position = SCNVector3(0, 0, -1) // 1 meter in front of camera
        scene.rootNode.addChildNode(circleNode)
    
        sceneView.scene = scene
        
        //Location Manager
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        //Test with Pins
        print("Set pins")
        let annotation = MKPointAnnotation()
        //Change latitude and longitude for pin-location on map
        let centerCoordinate = CLLocationCoordinate2D(latitude:50.553989, longitude:9.672046)
        annotation.coordinate = centerCoordinate
        annotation.title = "Dom Fulda"
        mapView.addAnnotation(annotation)
        print("Annotation \(annotation.coordinate)")
        
        //Enables the function to follow user current location
        mapView.userTrackingMode = .follow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading//.gravity
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // New functions:
    
    // MapView settings
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    // Get users current position
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        let latitude = coord.latitude
        let longitude = coord.longitude
        print("latitude: \(latitude)")
        print("longitude: \(longitude)")
        
        let bearing = locData.getBearingOfLocAndDest(longitude: longitude, latitude: latitude)
        
        let stringFromDouble:String = String(format:"%f", bearing)
        print("bearing \(bearing)")
        labelBearing.text = stringFromDouble
        
        if(!firstTime){
            translateAndRotateNode(with: GLKMathDegreesToRadians(Float(bearing)))
            firstTime = true
            print("translated and rotated node")
        }
        else{
            //circleNode.transform = SCNMatrix4MakeTranslation(0, 0, Float(-0.5))
            print("translated node")
        }
    }
    
    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        print("created sphereNode")
        return sphereNode
    }
    
    func translateAndRotateNode(with rotationY: Float){
        // Translate first on -z direction
        let translation = SCNMatrix4MakeTranslation(0, 0, Float(-100))
        // Rotate (yaw) around y axis
        let rotation = SCNMatrix4MakeRotation(-1 * rotationY, 0, 1, 0)
        // Final transformation: TxR
        circleNode.transform = SCNMatrix4Mult(translation, rotation)
    }
}
