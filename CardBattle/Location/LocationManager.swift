import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var didReport = false

    var onLongitude: ((Double) -> Void)?
    var onDenied: (() -> Void)?

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() {
        didReport = false
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !didReport, let location = locations.first else { return }
        didReport = true
        manager.stopUpdatingLocation()
        onLongitude?(location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !didReport else { return }
        didReport = true
        onDenied?()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            guard !didReport else { return }
            didReport = true
            onDenied?()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
}
