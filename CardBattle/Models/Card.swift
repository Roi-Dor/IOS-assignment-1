import Foundation

enum Side {
    case east
    case west
}

struct Card {
    let suitImageName: String
    let rank: Int
}

enum Deck {
    static let suits = ["Clubs", "Diamonds", "Hearts", "Spade"]
    static let minRank = 1
    static let maxRank = 13

    static func random() -> Card {
        Card(suitImageName: suits.randomElement()!,
             rank: Int.random(in: minRank...maxRank))
    }
}
