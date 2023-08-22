//
//  RMEpisode.swift
//  RickAndMorty
//
//  Created by Carson Gross on 4/24/23.
//

import Foundation

struct RMEpisode: Codable, RMEpisodeDateRender {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}
