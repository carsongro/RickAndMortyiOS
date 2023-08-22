//
//  RMSettingsView.swift
//  RickAndMorty
//
//  Created by Carson Gross on 8/20/23.
//

import SwiftUI

struct RMSettingsView: View {
    let viewModel: RMSettingsViewViewModel
    
    var body: some View {
        List(viewModel.cellViewModels) { viewModel in
            HStack {
                if let iconImage = viewModel.image {
                    Image(uiImage: iconImage)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color(uiColor: viewModel.iconContainerColor))
                        .cornerRadius(6)
                }
                Text(viewModel.title)
                    .padding(.leading, 10)
                
                Spacer()
            }
            .padding(.bottom, 3)
            .onTapGesture  {
                viewModel.onTapHandler(viewModel.type)
            }
        }
    }
}

struct RMSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        RMSettingsView(viewModel: .init(cellViewModels: RMSettingsOption.allCases.compactMap {
            RMSettingsCellViewModel(type: $0) { option in
                
            }
        }))
    }
}
