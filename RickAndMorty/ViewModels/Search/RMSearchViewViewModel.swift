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
    
    private var searchResultModel: Codable?
     
    // MARK: Init
    
    init(config: RMSearchViewController.Config) {
        self.config = config
    }
    
    // MARK: Public
    
    public func locationSearchResult(at index: Int) -> RMLocation? {
        guard let searchModel = searchResultModel as? RMGetAllLocationsResponse else {
            return nil
        }
        return searchModel.results[index]
    }
    
    public func characterSearchResult(at index: Int) -> RMCharacter? {
        guard let searchModel = searchResultModel as? RMGetAllCharactersResponse else {
            return nil
        }
        return searchModel.results[index]
    }
    
    public func episodeSearchResult(at index: Int) -> RMEpisode? {
        guard let searchModel = searchResultModel as? RMGetAllEpisodesResponse else {
            return nil
        }
        return searchModel.results[index]
    }
    
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
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty || !optionMap.isEmpty else {
            return
        }
        
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
    
    // MARK: Private
    
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
            case .failure:
                self?.handleNoResults()
            }
        }
    }
    
    private func processSearchResults(model: Codable) {
        var resultsVM: RMSearchResultsType?
        var nextURL: String?
        if let characterResults = model as? RMGetAllCharactersResponse {
            resultsVM = .characters(characterResults.results.compactMap {
                RMCharacterCollectionViewCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image)
                )
            })
            nextURL = characterResults.info.next
        } else if let episodeResults = model as? RMGetAllEpisodesResponse {
            resultsVM = .episodes(episodeResults.results.compactMap {
                RMCharacterEpisodeCollectionViewCellViewModel(
                    episodeDataURL: URL(string: $0.url)
                )
            })
            nextURL = episodeResults.info.next
        } else if let locationResults = model as? RMGetAllLocationsResponse {
            resultsVM = .locations(locationResults.results.compactMap {
                RMLocationTableViewCellViewModel(location: $0)
            })
            nextURL = locationResults.info.next
        }
        
        if let results = resultsVM {
            self.searchResultModel = model
            let vm = RMSearchResultsViewModel(results: results, next: nextURL)
            self.searchResultHandler?(vm)
        } else {
            handleNoResults()
        }
    }
    
    private func handleNoResults() {
        noResultsHandler?()
    }
}
