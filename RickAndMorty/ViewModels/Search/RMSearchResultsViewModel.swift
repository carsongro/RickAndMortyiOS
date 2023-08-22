//
//  RMSearchResultsViewModel.swift
//  RickAndMorty
//
//  Created by Carson Gross on 8/21/23.
//

import Foundation

enum RMSearchResultsViewModel {
    case characters([RMCharacterCollectionViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
}
