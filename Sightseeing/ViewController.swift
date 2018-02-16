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


class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var labelBearing: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D!
    var sphereData = SphereData()
    var firstTime: Bool = false
    var distance:Double!
    var metersLeft:Double = 0.0
    var diff:Double = 0.0
    
    var configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        mapView.delegate = self
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        mapView.showsScale = true
        
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
        
        //Create SphereData and add to scene
        scene.rootNode.addChildNode(sphereData.createSphereNode())
        scene.rootNode.addChildNode(sphereData.createTextNode())
        
        sceneView.scene = scene

        //Init Location Manager
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        //Enables the function to follow user current location
        mapView.userTrackingMode = .follow
    }
    
    // Making the Polyline visible by choosing a color and width
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        // Set the mapView's delegate
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //let configuration = ARWorldTrackingConfiguration()
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
    
    
    // NEW FUNCTIONS:
    
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
        
        //Set currentLocation
        currentLocation = coord
        
        //Put direction on the map
        let directions = MKDirections(request:DestinationData.getDirectionRequest(sourceCoordinates: currentLocation))
        directions.calculate(completionHandler: {
            response, error in
            // Error handling
            guard let response = response else {
                if let error = error {
                    print("Ups, there seem to be a problem")
                }
                return
            }
            //routes 0 : fastest route
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            // Starting position when view gets loaded
            let rectangle = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rectangle), animated: true)
            
        })
        
        //Get Distance
        distance = DestinationData.getDistance(currentLocation: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
        print("The real distance \(distance)")
        if(metersLeft == 0){
            metersLeft = distance
        }
        else{
            if((metersLeft - distance) > 0){
                metersLeft = metersLeft - distance
                diff = metersLeft - distance
            }
        }
        //Set label with km
        let stringFromDouble:String = String(format:"%.2f", distance)
        labelBearing.text = stringFromDouble + " meters left"
        
        let bearing = DestinationData.getBearingOfLocAndDest(longitude: longitude, latitude: latitude)
        //let stringFromDouble2:String = String(format:"%f", bearing)
        print("bearing: \(bearing)")
        //labelBearing.text = stringFromDouble2
        
        if(!firstTime){
            firstTime = true
            sphereData.editSphereData(rotationY: GLKMathDegreesToRadians(Float(bearing)), title: DestinationData.getCurrentDestinationAsString())
        }
        else{
            

            if(diff >= 500.0 && distance >= 500.0){
                //Reset scene
                sceneView.session.pause()
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
                }
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                
                //Create SphereData and add to scene
                let scene = SCNScene()
                scene.rootNode.addChildNode(sphereData.createSphereNode())
                scene.rootNode.addChildNode(sphereData.createTextNode())
                
                sceneView.scene = scene
                
                sphereData.editSphereData(rotationY: GLKMathDegreesToRadians(Float(bearing)), title: DestinationData.getCurrentDestinationAsString())
            }
            
            //circleNode.transform = SCNMatrix4MakeTranslation(0, 0, Float(-0.5))
        }
    }
    
    /*
     
        CODE DOWN BELOW NOT RELEVANT FOR THE PROJECT RIGHT NOW
     
     */
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
    
}
