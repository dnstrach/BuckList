//
//  EditView-ViewModel.swift
//  Bucketlist
//
//  Created by Dominique Strachan on 1/2/24.
//

import SwiftUI

extension EditView {
    @MainActor class EditViewModel: ObservableObject {
         enum LoadingState {
            case loading, loaded, failed
         }
        
        @Published var name: String
        @Published var description: String
        
        @Published var loadingState = LoadingState.loading
        @Published var pages = [Page]()
        
        var location: Location
        
        init(location: Location) {
            name = location.name
            description = location.description
            self.location = location
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let items = try JSONDecoder().decode(Result.self, from: data)
                pages = items.query.pages.values.sorted()
                // pages = items.query.pages.values.sorted { $0.title < $1.title}
                loadingState = .loaded
            } catch {
                print(error.localizedDescription)
                loadingState = .failed
            }
        }
        
        func createNewLocation() -> Location {
            var newLocation = location
            newLocation.id = UUID()
            newLocation.name = name
            newLocation.description = description
            return newLocation  
        }
    }
}
