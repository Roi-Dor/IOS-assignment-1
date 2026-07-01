import UIKit

final class SummaryViewController: UIViewController {
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var backToMenuButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        winnerLabel.text = "Winner: \(GameState.shared.winnerName)"
        scoreLabel.text = "score: \(GameState.shared.winnerScore)"
    }

    @IBAction func backToMenuTapped(_ sender: UIButton) {
        GameState.shared.resetForNewGame()
        performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
}
