//
//  RMLocationTableViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Carson Gross on 8/20/23.
//

import Foundation

struct RMLocationTableViewCellViewModel: Hashable, Equatable {
    
    private let location: RMLocation
    
    init(location: RMLocation) {
        self.location = location
    }
    
    public var name: String {
        location.name
    }
    
    public var type: String {
        "Type: " + location.type
    }
    
    public var dimension: String {
        location.dimension
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location.id)
        hasher.combine(dimension)
        hasher.combine(type)
    }
    
    static func == (lhs: RMLocationTableViewCellViewModel, rhs: RMLocationTableViewCellViewModel) -> Bool {
        lhs.location.id == rhs.location.id
    }
}
