import UIKit

final class MenuViewController: UIViewController {
    @IBOutlet weak var insertNameButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var startButton: UIButton!

    private let locationManager = LocationManager()
    private var didStartLocating = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshNameUI()
        updateStartButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ProcessInfo.processInfo.environment["AUTOGAME"] != nil {
            GameState.shared.setName("Roi")
            GameState.shared.assignSide(longitude: 35.0)
            performSegue(withIdentifier: "toGame", sender: self)
            return
        }
        guard !didStartLocating else { return }
        didStartLocating = true
        beginLocating()
    }

    private func beginLocating() {
        statusLabel.text = "Locating…"
        activityIndicator.startAnimating()

        locationManager.onLongitude = { [weak self] longitude in
            DispatchQueue.main.async {
                guard let self = self else { return }
                GameState.shared.assignSide(longitude: longitude)
                self.activityIndicator.stopAnimating()
                self.statusLabel.text = "You are on the \(GameState.shared.playerSideLabel)"
                self.updateStartButton()
            }
        }

        locationManager.onDenied = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                self.statusLabel.text = "Location permission needed — enable it in Settings."
                self.updateStartButton()
            }
        }

        locationManager.start()
    }

    private func refreshNameUI() {
        let name = GameState.shared.playerName
        let hasName = !name.isEmpty
        nameLabel.text = name
        nameLabel.isHidden = !hasName
        insertNameButton.isHidden = hasName
    }

    private func updateStartButton() {
        let enabled = GameState.shared.canStart
        startButton.isHidden = !enabled
        startButton.isEnabled = enabled
    }

    @IBAction func insertNameTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter your name", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Name"
            field.text = GameState.shared.playerName
            field.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak alert] _ in
            let text = alert?.textFields?.first?.text ?? ""
            GameState.shared.setName(text)
            self?.refreshNameUI()
            self?.updateStartButton()
        })
        present(alert, animated: true)
    }

    @IBAction func startTapped(_ sender: UIButton) {
        guard GameState.shared.canStart else { return }
        performSegue(withIdentifier: "toGame", sender: self)
    }

    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        // Return point for the unwind segue from Summary.
    }
}
