//
//  ContentView-ViewModel.swift
//  Bucketlist
//
//  Created by Dominique Strachan on 1/2/24.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    // need @MainActor because UI won't be updated
    // did not need to include @MainActor before bc properties used @StateObject or @ObservedObject
    @MainActor class ViewModel: ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        // private(set) - can read data, but only class can write new data
        // @Published private(set) var locations = [Location]()
        @Published private(set) var locations: [Location]
        @Published var selectedPlace: Location?
        @Published var isUnlocked = false
        @Published var showAuthError = false
        @Published var authErrorMessage = "Unknown Error"
        
        let savedPath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savedPath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savedPath, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    Task { @MainActor in
                        if success {
                            // change UI with background task
                            self.isUnlocked = true
                            
                            //                        Task {
                            //                            await MainActor.run {
                            //                                self.isUnlocked = true
                            //                            }
                            //                        }
                        } else {
                            // error
                            self.authErrorMessage = "There was a problem authenticating you; please try again."
                            self.showAuthError = true
                        }
                    }
                }
            } else {
                // no biometrics
                self.authErrorMessage = "Sorry, your device does not support biometrics authentication."
                self.showAuthError = true
            }
        }
        
    }
}
