//
//  LocationData.swift
//  Sightseeing
//
//  Created by Dominik Kura on 01.02.18.
//  Copyright © 2018 Dominik Kura & Aleksandar Mitkovski. All rights reserved.
//

import CoreLocation
import MapKit

class DestinationData{

    // "List" of destinations. Structure: [[latitude,longitude], [latitude,longitude], ...]
    static var destinations: [[Double]] = [[50.553982,9.672056], [50.569736,9.690135], [50.549624,9.675762],[56.8790,14.8059]]
    // "List of destination names.
    static var destinationStrings: [String] = ["Dom", "Hochschule Fulda", "Bermuda Dreieck", "Växjö"]
    
    // Test / Init
    static var currentDestLat:Double = 50.553982
    static var currentDestLong:Double = 9.672056
    static var currentDestinationString: String = "Dom"
    static var currentDestination:CLLocation!
    
    
    //Setting the current destination
    static func setCurrentDest(locationNumber:Int){
        print("Invoked setCurrentDest in DestinationData")
        if(locationNumber < destinations.count){
            currentDestLat = destinations[locationNumber][0]
            currentDestLong = destinations[locationNumber][1]
            currentDestination = CLLocation(latitude: currentDestLat, longitude: currentDestLong)
            currentDestinationString = destinationStrings[locationNumber]
        }
        else{
            print("Error! Wrong location number!")
        }
    }
    //Returns the coordinates as CLLocationCoordinate2D Object
    static func getCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: currentDestLat, longitude: currentDestLong)
    }
    
    // Returns a 2D-Array value with longitude and latiude of location
    static func getDestinationCoords(locationNumber:Int) -> [Double]{
        return destinations[locationNumber]
    }
    
    // Calculate Bearing between current position and destination
    static func getBearingOfLocAndDest(longitude: Double, latitude: Double) -> Double{
        let lat1Rad = latitude * .pi / 180;
        let lat2Rad = currentDestLat * .pi / 180;
        
        let dLon = (currentDestLong - longitude) * .pi/180
        
        let y = sin(dLon) * cos(lat2Rad)
        let x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon)
        
        let bearingRad = atan2(y,x)
        
        return fmod((bearingRad * 180 / .pi + 360 ),360)
    }
    
    static func getDirectionRequest(sourceCoordinates:CLLocationCoordinate2D) -> MKDirectionsRequest{
        
        let destCoordinates = CLLocationCoordinate2D(latitude: currentDestLat, longitude: currentDestLong)
      
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinates)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        //MapItem Creation for getting direction
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .walking

        return directionRequest
    }
    
    static func getDistance(currentLocation: CLLocation) -> CLLocationDistance{
        let distance = currentLocation.distance(from: currentDestination)
        return distance
    }
    
    static func getCurrentDestinationAsString() -> String{
        return currentDestinationString
    }
    

}
