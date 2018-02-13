//
//  DestinationView.swift
//  Sightseeing
//
//  Created by Dominik Kura on 13.02.18.
//  Copyright © 2018 Dominik Kura. All rights reserved.
//

import UIKit

class DestinationViewController: UITableViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("indexPath: \(indexPath)")
        DestinationData.setCurrentDest(locationNumber: indexPath[1])
    }
}
