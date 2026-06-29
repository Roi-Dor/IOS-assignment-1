import Foundation
import Combine

let MIDPOINT_LONGITUDE = 34.817549168324334

@MainActor
final class GameState: ObservableObject {
    static let totalRounds = 10
    static let pcName = "PC"
    private static let nameKey = "playerName"

    @Published var screen: Screen = .menu
    @Published var playerName: String
    @Published var side: Side?
    @Published var playerScore: Int = 0
    @Published var pcScore: Int = 0
    @Published var round: Int = 0

    // Card display state
    @Published var playerCard: Card?
    @Published var pcCard: Card?
    @Published var cardsFaceUp: Bool = false

    init() {
        playerName = UserDefaults.standard.string(forKey: Self.nameKey) ?? ""
    }

    var playerSideLabel: String {
        switch side {
        case .east: return "East Side"
        case .west: return "West Side"
        case nil:   return ""
        }
    }

    var canStart: Bool {
        !playerName.isEmpty && side != nil
    }

    func assignSide(longitude: Double) {
        side = longitude > MIDPOINT_LONGITUDE ? .east : .west
    }

    func setName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        playerName = trimmed
        UserDefaults.standard.set(trimmed, forKey: Self.nameKey)
    }

    func startGame() {
        playerScore = 0
        pcScore = 0
        round = 0
        playerCard = nil
        pcCard = nil
        cardsFaceUp = false
        screen = .game
    }

    func endGame() {
        screen = .summary
    }

    func resetToMenu() {
        playerScore = 0
        pcScore = 0
        round = 0
        playerCard = nil
        pcCard = nil
        cardsFaceUp = false
        screen = .menu
    }

    // House (PC) wins ties — never a displayed draw.
    var winnerName: String {
        playerScore > pcScore ? playerName : Self.pcName
    }

    var winnerScore: Int {
        max(playerScore, pcScore)
    }
}
