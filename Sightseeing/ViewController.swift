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

extension CLLocationCoordinate2D{
    func distance(from:CLLocationCoordinate2D) -> CLLocationDistance{
        let sourceCoordinates = CLLocation(latitude: 56.8790, longitude: 14.8059)
        return CLLocation(latitude: 55.6050, longitude: 13.0038).distance(from: sourceCoordinates)
    }
}


class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var labelBearing: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    var locationManager: CLLocationManager!
    //var locData = DestinationData()
    var sphereData = SphereData()
    var firstTime: Bool = false
    
    override func viewDidLoad() {
        print("View did load")
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
        
        // Test with Pins
        /* let annotation = MKPointAnnotation()
        // Change latitude and longitude for pin-location on map
        let centerCoordinate = CLLocationCoordinate2D(latitude:50.553989, longitude:9.672046)
        annotation.coordinate = centerCoordinate
        annotation.title = "Dom Fulda"
        mapView.addAnnotation(annotation)
        print("Annotation \(annotation.coordinate)")
        */
        //Enables the function to follow user current location
        mapView.userTrackingMode = .follow
 
        //let sourceCoordinates = locationManager.location?.coordinate
        // City: Växjö
        let sourceCoordinates = CLLocationCoordinate2D(latitude: 56.8790, longitude: 14.8059)
        // City: Malmö
        let destCoordinates = CLLocationCoordinate2D(latitude: 55.6050, longitude: 13.0038)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinates)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        let distance = sourceCoordinates.distance(from: destCoordinates) / 1000
        print(String(format: "Distance between Växjö and Mämo is: %.01fkm", distance))
        
        
        //Destination between two coordinates
        //!!!IS BUGGY
        //let routeDistance : CLLocationDistance = sourceCoordinates.distanceFromLocation(destCoordinates)
        
        //MapItem Creation for getting direction
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        
        directionRequest.transportType = .walking
        
        //Put direction on the map
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            // Error handling
            guard let response = response else {
                if let error = error {
                    print("Ups, there seem to be a problem")
                }
                return
            }
            //routes 0 : fastes route
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            // Starting Postion when application gets started
            let rectangle = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rectangle), animated: true)
        })
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
        
      
        let bearing = DestinationData.getBearingOfLocAndDest(longitude: longitude, latitude: latitude)
        let stringFromDouble:String = String(format:"%f", bearing)
        print("bearing: \(bearing)")
        labelBearing.text = stringFromDouble
        
        if(!firstTime){
            firstTime = true
            sphereData.editSphereData(rotationY: GLKMathDegreesToRadians(Float(bearing)))
        }
        else{
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
