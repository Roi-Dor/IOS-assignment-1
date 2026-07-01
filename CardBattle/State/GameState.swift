import Foundation

let MIDPOINT_LONGITUDE = 34.817549168324334

final class GameState {
    static let shared = GameState()
    private init() {}

    private let nameKey = "playerName"
    static let pcName = "PC"

    var playerName: String {
        get { UserDefaults.standard.string(forKey: nameKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: nameKey) }
    }

    var side: Side?
    var playerScore = 0
    var pcScore = 0
    var round = 0

    func assignSide(longitude: Double) {
        side = longitude > MIDPOINT_LONGITUDE ? .east : .west
    }

    func setName(_ name: String) {
        playerName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canStart: Bool {
        !playerName.isEmpty && side != nil
    }

    func resetForNewGame() {
        playerScore = 0
        pcScore = 0
        round = 0
    }

    var winnerName: String {
        playerScore > pcScore ? playerName : GameState.pcName
    }

    var winnerScore: Int {
        max(playerScore, pcScore)
    }

    var playerSideLabel: String {
        switch side {
        case .east: return "East Side"
        case .west: return "West Side"
        case .none: return ""
        }
    }
}
