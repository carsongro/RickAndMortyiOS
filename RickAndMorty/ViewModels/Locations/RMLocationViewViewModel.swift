//
//  RMLocationViewViewModel.swift
//  RickAndMorty
//
//  Created by Carson Gross on 8/20/23.
//

import Foundation

protocol RMLocationViewViewModelDelegate: AnyObject {
    func didFetchInitialLocations()
}

final class RMLocationViewViewModel {
    
    weak var delegate: RMLocationViewViewModelDelegate?
    
    private var locations = [RMLocation]() {
        didSet {
            locations.forEach { location in
                let cellViewModel = RMLocationTableViewCellViewModel(location: location)
                if !cellViewModels.contains(cellViewModel) {
                    cellViewModels.append(cellViewModel)
                }
            }
        }
    }
    
    public var isLoadingMoreLocations = false
    public var shouldShowLoadMoreIndicator: Bool {
        apiInfo?.next != nil
    }
    
    private var didFinishPagination: (() -> Void)?
    
    // Location response info
    // Will contain next url if present
    private var apiInfo: RMGetAllLocationsResponse.Info?
    
    public private(set) var cellViewModels = [RMLocationTableViewCellViewModel]()
    
    private var hasMoreResults: Bool {
        false
    }
    
    // MARK: Init
    
    init() {
        
    }
    
    // MARK: Public
    
    public func location(at index: Int) -> RMLocation? {
        guard index < locations.count && index >= 0 else {
            return nil
        }
        
        return locations[index]
    }
    
    public func registerDidFinishPaginationBlock(_ block: @escaping () -> Void) {
        self.didFinishPagination = block
    }
    
    /// Paginate if additional locations are needed
    public func fetchAdditionalLocations() {
        guard let nextURLString = apiInfo?.next,
              let url = URL(string: nextURLString),
              !isLoadingMoreLocations else {
            return
        }
        
        isLoadingMoreLocations = true
        
        guard let request = RMRequest(url: url) else {
            isLoadingMoreLocations = false
            return
        }
        
        RMService.shared.execute(request, expecting: RMGetAllLocationsResponse.self) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let responseModel):
                let moreResults = responseModel.results
                let info = responseModel.info
                self.apiInfo = info
                self.locations.append(contentsOf: moreResults)
                DispatchQueue.main.async {
                    // Notify via callback
                    self.isLoadingMoreLocations = false
                    self.didFinishPagination?()
                }
            case .failure(let failure):
                print(String(describing: failure))
                self.isLoadingMoreLocations = false
            }
        }
    }
    
    public func fetchLocations() {
        RMService.shared.execute(
            .listLocationsRequest,
            expecting: RMGetAllLocationsResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let model):
                self?.apiInfo = model.info
                self?.locations = model.results
                DispatchQueue.main.async {
                    self?.delegate?.didFetchInitialLocations()
                }
            case .failure:
                break
            }
        }
    }
}
