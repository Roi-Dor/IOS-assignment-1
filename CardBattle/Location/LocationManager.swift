import Foundation
import CoreLocation

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    enum Status {
        case idle, locating, done, denied
    }

    @Published var longitude: Double?
    @Published var status: Status = .idle

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() {
        guard status != .locating, longitude == nil else { return }
        status = .locating
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        let lon = first.coordinate.longitude
        manager.stopUpdatingLocation()
        Task { @MainActor in
            self.longitude = lon
            self.status = .done
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        Task { @MainActor in
            if self.longitude == nil {
                self.status = .denied
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authStatus = manager.authorizationStatus
        Task { @MainActor in
            switch authStatus {
            case .denied, .restricted:
                self.status = .denied
            case .authorizedWhenInUse, .authorizedAlways:
                if self.longitude == nil {
                    manager.requestLocation()
                }
            default:
                break
            }
        }
    }
}
