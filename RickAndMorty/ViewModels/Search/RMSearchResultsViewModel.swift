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
    
    public var showShowLoadMoreIndicator: Bool {
        next != nil
    }
}
