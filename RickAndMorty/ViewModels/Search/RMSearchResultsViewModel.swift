//
//  RMSearchResultsViewModel.swift
//  RickAndMorty
//
//  Created by Carson Gross on 8/22/23.
//

import Foundation

final class RMSearchResultsViewModel {
    public private(set) var results: RMSearchResultsType
    private var next: String?
    public private(set) var isLoadingMoreResults = false
    
    init(results: RMSearchResultsType, next: String?) {
        self.results = results
        self.next = next
    }
    
    public func fetchAdditionalResults(completion: @escaping ([any Hashable]) -> Void) {
        guard let nextURLString = next,
              let url = URL(string: nextURLString),
              !isLoadingMoreResults else {
            return
        }
        
        isLoadingMoreResults = true
        
        guard let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            return
        }
        
        switch results {
        case .characters(let existingResults):
            RMService.shared.execute(request, expecting: RMGetAllCharactersResponse.self) { [weak self] result in
                guard let self else { return }
                
                var newResults = [RMCharacterCollectionViewCellViewModel]()
                
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    let info = responseModel.info
                    self.next = info.next // Capture new pagination url
                    
                    let additionalLocations = moreResults.compactMap {
                        RMCharacterCollectionViewCellViewModel(
                            characterName: $0.name,
                            characterStatus: $0.status,
                            characterImageUrl: URL(string: $0.image)
                        )
                    }
                    newResults = existingResults + additionalLocations
                    self.results = .characters(newResults)
                    
                    DispatchQueue.main.async {
                        // Notify via callback
                        self.isLoadingMoreResults = false
                        completion(newResults)
                    }
                case .failure(let failure):
                    print(String(describing: failure))
                    self.isLoadingMoreResults = false
                }
            }
        case .episodes(let existingResults):
            RMService.shared.execute(request, expecting: RMGetAllEpisodesResponse.self) { [weak self] result in
                guard let self else { return }
                
                var newResults = [RMCharacterEpisodeCollectionViewCellViewModel]()
                
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    let info = responseModel.info
                    self.next = info.next // Capture new pagination url
                    
                    let additionalLocations = moreResults.compactMap {
                        RMCharacterEpisodeCollectionViewCellViewModel(episodeDataURL: URL(string: $0.url))
                    }
                    newResults = existingResults + additionalLocations
                    self.results = .episodes(newResults)
                    
                    DispatchQueue.main.async {
                        // Notify via callback
                        self.isLoadingMoreResults = false
                        completion(newResults)
                    }
                case .failure(let failure):
                    print(String(describing: failure))
                    self.isLoadingMoreResults = false
                }
            }
        case .locations:
            // TableView case
            break
        }
    }
    
    public func fetchAdditionalLocations(completion: @escaping ([RMLocationTableViewCellViewModel]) -> Void) {
        guard let nextURLString = next,
              let url = URL(string: nextURLString),
              !isLoadingMoreResults else {
            return
        }
        
        isLoadingMoreResults = true
        
        guard let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            return
        }
        
        RMService.shared.execute(request, expecting: RMGetAllLocationsResponse.self) { [weak self] result in
            guard let self else { return }
            
            var newResults = [RMLocationTableViewCellViewModel]()
            
            switch result {
            case .success(let responseModel):
                let moreResults = responseModel.results
                let info = responseModel.info
                self.next = info.next // Capture new pagination url
                
                let additionalLocations = moreResults.compactMap {
                    RMLocationTableViewCellViewModel(location: $0)
                }
                
                switch self.results {
                case .locations(let existingResults):
                    newResults = existingResults + additionalLocations
                    self.results = .locations(newResults)
                case .characters, .episodes:
                    break
                }
                
                DispatchQueue.main.async {
                    // Notify via callback
                    self.isLoadingMoreResults = false
                    completion(newResults)
                }
            case .failure(let failure):
                print(String(describing: failure))
                self.isLoadingMoreResults = false
            }
        }
    }
    
    public var shouldShowLoadMoreIndicator: Bool {
        next != nil
    }
}
