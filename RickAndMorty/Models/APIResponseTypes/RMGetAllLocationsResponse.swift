//
//  RMGetAllLocationsResponse.swift
//  RickAndMorty
//
//  Created by Carson Gross on 8/20/23.
//

import Foundation

struct RMGetAllLocationsResponse: Codable {
    struct Info: Codable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
    
    let info: Info
    let results: [RMLocation]
}
