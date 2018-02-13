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
    static var destinationArray: [[Double]] = [[50.553982,9.672056], [50.569736,9.690135]]
    
    // Test
    static var currentDestLat:Double = 50.553982
    static var currentDestLong:Double = 9.672056
    
    //Setting the current destination
    static func setCurrentDest(locationNumber:Int){
        print("Invoked setCurrentDest in DestinationData")
        if(locationNumber < destinationArray.count){
            currentDestLat = destinationArray[locationNumber][0]
            currentDestLong = destinationArray[locationNumber][1]
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
        return destinationArray[locationNumber]
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
    
}
