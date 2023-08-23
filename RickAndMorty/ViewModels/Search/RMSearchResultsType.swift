//
//  RMSearchResultsType.swift
//  RickAndMorty
//
//  Created by Carson Gross on 8/21/23.
//

import Foundation

enum RMSearchResultsType {
    case characters([RMCharacterCollectionViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
}
