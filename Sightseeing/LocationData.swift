//
//  LocationData.swift
//  Sightseeing
//
//  Created by Dominik Kura on 01.02.18.
//  Copyright © 2018 Dominik Kura & Aleksandar Mitkovski. All rights reserved.
//

import CoreLocation

class LocationData{

    // "List" of destinations. Structure: [[latitude,longitude], [latitude,longitude], ...]
    var destinationArray: [[Double]] = [[50.553982,9.672056], [50.569736,9.690135]]
    
    var currentDestLat:Double = 50.568426//50.553982 //50.569736
    var currentDestLong:Double = 9.690574//9.672056 //9.690135
    
    func setCurrentDest(locationNumber:Int){
        if(locationNumber < destinationArray.count){
            currentDestLat = destinationArray[locationNumber][0]
            currentDestLong = destinationArray[locationNumber][1]
        }
        else{
            print("Error! Wrong location number!")
        }
    }
    
    // Returns a 2D-Array value with longitude and latiude of location
    func getDestinationCoords(locationNumber:Int) -> [Double]{
        return destinationArray[locationNumber]
    }
    
    // Calculate Bearing between current position and destination
    func getBearingOfLocAndDest(longitude: Double, latitude: Double) -> Double{
        print("Get bearing func:")
        print("lat \(latitude)")
        print("long \(longitude)")
        print("destlat \(currentDestLat)")
        print("destlong \(currentDestLong)")
        
        let lat1Rad = latitude * .pi / 180;
        let lat2Rad = currentDestLat * .pi / 180;
        
        let dLon = (currentDestLong - longitude) * .pi/180
        
        let y = sin(dLon) * cos(lat2Rad)
        let x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon)
        
        let bearingRad = atan2(y,x)
        
        return fmod((bearingRad * 180 / .pi + 360 ),360)
    }
    
}
