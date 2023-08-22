//
//  RMSearchViewViewModel.swift
//  RickAndMorty
//
//  Created by Carson Gross on 8/20/23.
//

import Foundation

/// Responsibilities:
/// - Show search results
/// - Show no results view
/// - kick of API requests

final class RMSearchViewViewModel {
    let config: RMSearchViewController.Config
    private var optionMap = [RMSearchInputViewViewModel.DynamicOption: String]()
    private var searchText = ""
    
    private var optionMapUpdateBlock: (((RMSearchInputViewViewModel.DynamicOption, String)) -> Void)?
    private var searchResultHandler: ((RMSearchResultsViewModel) -> Void)?
    private var noResultsHandler: (() -> Void)?
    
    // MARK: Init
    
    init(config: RMSearchViewController.Config) {
        self.config = config
    }
    
    // MARK: Public
    
    public func registerSearchResultsHandler(_ block: @escaping (RMSearchResultsViewModel) -> Void) {
        self.searchResultHandler = block
    }
    
    public func registerNoResultsHandler(_ block: @escaping () -> Void) {
        self.noResultsHandler = block
    }
    
    public func set(query text: String) {
        self.searchText = text
    }
    
    public func set(value: String, for option: RMSearchInputViewViewModel.DynamicOption) {
        optionMap[option] = value
        let tuple = (option, value)
        optionMapUpdateBlock?(tuple)
    }
    
    public func registerOptionChangeBlock(
        _ block: @escaping ((RMSearchInputViewViewModel.DynamicOption, String)) -> Void
    ) {
        self.optionMapUpdateBlock = block
        
    }
    
    public func executeSearch() {
        
        // Build Arguments
        var queryParams = [URLQueryItem(name: "name", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))]
        queryParams.append(contentsOf: optionMap.enumerated().compactMap { _, element in
            let key = element.key.queryArgument
            let value = element.value
            return URLQueryItem(name: key, value: value)
        })
        
        // Create request
        let request = RMRequest(
            endpoint: config.type.endpoint,
            queryParameters: queryParams
        )
        
        switch config.type.endpoint {
        case .character:
            makeSearchAPICall(RMGetAllCharactersResponse.self, request: request)
        case .episode:
            makeSearchAPICall(RMGetAllEpisodesResponse.self, request: request)
        case .location:
            makeSearchAPICall(RMGetAllLocationsResponse.self, request: request)
        }
    }
    
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: RMRequest) {
        // Execute request
        RMService.shared.execute(
            request,
            expecting: type
        ) { [weak self] result in
            // Notify view of results
            switch result {
            case .success(let model):
                self?.processSearchResults(model: model)
            case .failure(let error):
                self?.handleNoResults()
            }
        }
    }
    
    private func processSearchResults(model: Codable) {
        var resultsVM: RMSearchResultsViewModel?
        if let characterResults = model as? RMGetAllCharactersResponse {
            resultsVM = .characters(characterResults.results.compactMap {
                RMCharacterCollectionViewCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image)
                )
            })
        } else if let episodeResults = model as? RMGetAllEpisodesResponse {
            resultsVM = .episodes(episodeResults.results.compactMap {
                RMCharacterEpisodeCollectionViewCellViewModel(
                    episodeDataURL: URL(string: $0.url)
                )
            })
        } else if let locationResults = model as? RMGetAllLocationsResponse {
            resultsVM = .locations(locationResults.results.compactMap {
                RMLocationTableViewCellViewModel(location: $0)
            })
        }
        
        if let results = resultsVM {
            self.searchResultHandler?(results)
        } else {
            handleNoResults()
        }
    }
    
    private func handleNoResults() {
        noResultsHandler?()
    }
}
