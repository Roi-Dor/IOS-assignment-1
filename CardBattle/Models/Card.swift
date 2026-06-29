import Foundation

enum Suit: CaseIterable {
    case hearts, diamonds, spades, clubs

    /// Asset-catalog image name for the playing-card suit.
    var imageName: String {
        switch self {
        case .hearts:   return "Hearts"
        case .diamonds: return "Diamonds"
        case .spades:   return "Spade"
        case .clubs:    return "Clubs"
        }
    }

    /// Real playing cards: hearts/diamonds are red, spades/clubs are black.
    var isRed: Bool {
        self == .hearts || self == .diamonds
    }
}

struct Card: Identifiable, Equatable {
    let id = UUID()
    let suit: Suit
    let strength: Int       // 1...14 (rank: ...10 < J(11) < Q(12) < K(13) < A(14))

    var imageName: String { suit.imageName }

    /// What to print on the card: numbers for 1–10, letters for face cards / ace.
    var rankLabel: String {
        switch strength {
        case 14: return "A"
        case 13: return "K"
        case 12: return "Q"
        case 11: return "J"
        default: return "\(strength)"
        }
    }

    /// A full deck: every suit across all ranks 1–10 plus J, Q, K, A.
    static let deck: [Card] = Suit.allCases.flatMap { suit in
        (1...14).map { rank in Card(suit: suit, strength: rank) }
    }

    static func random() -> Card {
        deck.randomElement()!
    }
}
