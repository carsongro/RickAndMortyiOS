//
//  RMEndpoint.swift
//  RickAndMorty
//
//  Created by Carson Gross on 4/26/23.
//

import Foundation

/// Represents unique API enpoint
@frozen enum RMEndpoint: String, CaseIterable, Hashable {
    /// Endpoint to get character info
    case character
    /// Endpoint to get location info
    case location
    /// Endpoint to get episode info
    case episode
}
