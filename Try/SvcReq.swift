//
//  SvcReq.swift
//  Try
//
//  Created by Hazem Tariq on 12/9/20.
//

import Foundation
class SvcReq : Codable {
    var id = ""
    var custUName: String = ""
    var provUName: String = ""
    var svcLat = 0.0
    var svcLng = 0.0
    var svcAddr: String = ""
    var accepted = false
//    var driverLat = 0.0
//    var driverLng = 0.0
}
