import UIKit

final class GameViewController: UIViewController {
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var pcScoreLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerCardView: UIView!
    @IBOutlet weak var pcCardView: UIView!
    @IBOutlet weak var playerCardImageView: UIImageView!
    @IBOutlet weak var pcCardImageView: UIImageView!
    @IBOutlet weak var playerBackImageView: UIImageView!
    @IBOutlet weak var pcBackImageView: UIImageView!
    @IBOutlet weak var playerValueLabel: UILabel!
    @IBOutlet weak var pcValueLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!

    private var timer: Timer?
    private let totalRounds = 10
    private let cardFaceColor = UIColor.systemBackground

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        playerNameLabel.text = GameState.shared.playerName
        styleCard(playerCardView)
        styleCard(pcCardView)
        showBacks()
        updateScores()
        roundLabel.text = "Round 0 / \(totalRounds)"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GameState.shared.resetForNewGame()
        updateScores()
        startNextRound()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    private func startNextRound() {
        GameState.shared.round += 1
        let current = GameState.shared.round
        roundLabel.text = "Round \(current) / \(totalRounds)"

        let playerCard = Deck.random()
        let pcCard = Deck.random()

        flipUp(playerCardView, back: playerBackImageView, image: playerCardImageView, value: playerValueLabel, card: playerCard)
        flipUp(pcCardView, back: pcBackImageView, image: pcCardImageView, value: pcValueLabel, card: pcCard)

        if playerCard.rank > pcCard.rank {
            GameState.shared.playerScore += 1
        } else if pcCard.rank > playerCard.rank {
            GameState.shared.pcScore += 1
        }
        updateScores()

        // Face-up for 3s, then flip to backs.
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.showBacksAnimated()
            // Remaining 2s of the 5s round, then continue or finish.
            self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                if GameState.shared.round >= self.totalRounds {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.performSegue(withIdentifier: "toSummary", sender: self)
                } else {
                    self.startNextRound()
                }
            }
        }
    }

    private func styleCard(_ card: UIView) {
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.separator.cgColor
        card.clipsToBounds = true
        card.backgroundColor = cardFaceColor
    }

    private func flipUp(_ card: UIView, back: UIImageView, image: UIImageView, value: UILabel, card model: Card) {
        UIView.transition(with: card, duration: 0.4, options: .transitionFlipFromLeft) {
            image.image = UIImage(named: model.suitImageName)
            image.isHidden = false
            value.text = "\(model.rank)"
            value.isHidden = false
            back.isHidden = true
        }
    }

    private func showBacksAnimated() {
        for card in [(playerCardView, playerBackImageView, playerCardImageView, playerValueLabel),
                     (pcCardView, pcBackImageView, pcCardImageView, pcValueLabel)] {
            UIView.transition(with: card.0!, duration: 0.4, options: .transitionFlipFromRight) {
                card.1?.isHidden = false
                card.2?.isHidden = true
                card.3?.isHidden = true
            }
        }
    }

    private func showBacks() {
        for card in [(playerBackImageView, playerCardImageView, playerValueLabel),
                     (pcBackImageView, pcCardImageView, pcValueLabel)] {
            card.0?.isHidden = false
            card.1?.isHidden = true
            card.2?.isHidden = true
        }
    }

    private func updateScores() {
        playerScoreLabel.text = "\(GameState.shared.playerName): \(GameState.shared.playerScore)"
        pcScoreLabel.text = "\(GameState.pcName): \(GameState.shared.pcScore)"
    }
}
