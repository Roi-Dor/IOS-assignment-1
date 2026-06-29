import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState

    @State private var gameTask: Task<Void, Never>?
    @State private var secondsLeft = 5

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            Group {
                if isLandscape {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear { startLoop() }
        .onDisappear {
            gameTask?.cancel()
            gameTask = nil
        }
    }

    // Roomy vertical layout for portrait.
    private var portraitLayout: some View {
        VStack(spacing: 24) {
            scoreboard
            roundText
            Spacer()
            cardsRow
            countdownText
                .font(.system(size: 40, weight: .bold, design: .rounded))
            Spacer()
        }
        .padding()
    }

    // Compact, centered layout that fits the short height in landscape.
    private var landscapeLayout: some View {
        VStack(spacing: 10) {
            scoreboard
            HStack(spacing: 8) {
                roundText
                Text("·").foregroundColor(.secondary)
                countdownText.font(.headline)
            }
            cardsRow
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .frame(maxHeight: .infinity)
    }

    private var roundText: some View {
        Text("Round \(min(gameState.round + 1, GameState.totalRounds)) / \(GameState.totalRounds)")
            .font(.headline)
    }

    private var countdownText: some View {
        Text("\(secondsLeft)")
            .foregroundColor(.secondary)
    }

    private var cardsRow: some View {
        HStack(spacing: 24) {
            VStack {
                CardView(card: gameState.playerCard, faceUp: gameState.cardsFaceUp)
                Text(playerLabel).font(.subheadline)
            }
            Text("VS").font(.title2).bold()
            VStack {
                CardView(card: gameState.pcCard, faceUp: gameState.cardsFaceUp)
                Text(GameState.pcName).font(.subheadline)
            }
        }
    }

    private var playerLabel: String {
        gameState.playerName.isEmpty ? "You" : gameState.playerName
    }

    private var scoreboard: some View {
        // Grouped near the top-center so the numbers never land in the
        // rounded corners / camera cutout (which clip them in landscape).
        // Order still reflects the player's assigned side.
        HStack(spacing: 32) {
            let playerOnLeft = gameState.side == .west
            if playerOnLeft {
                scoreCell(name: playerLabel, score: gameState.playerScore)
                Divider().frame(height: 44)
                scoreCell(name: GameState.pcName, score: gameState.pcScore)
            } else {
                scoreCell(name: GameState.pcName, score: gameState.pcScore)
                Divider().frame(height: 44)
                scoreCell(name: playerLabel, score: gameState.playerScore)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .frame(maxWidth: .infinity)
    }

    private func scoreCell(name: String, score: Int) -> some View {
        VStack(spacing: 2) {
            Text(name).font(.headline)
            Text("\(score)").font(.title).bold()
        }
        .frame(minWidth: 80)
    }

    private func startLoop() {
        guard gameTask == nil else { return }
        gameTask = Task { await runGame() }
    }

    private func runGame() async {
        for r in 0..<GameState.totalRounds {
            if Task.isCancelled { return }
            gameState.round = r

            // Flip up: pick new cards and score.
            let player = Card.random()
            let pc = Card.random()
            gameState.playerCard = player
            gameState.pcCard = pc
            gameState.cardsFaceUp = true
            secondsLeft = 5

            if player.strength > pc.strength {
                gameState.playerScore += 1
            } else if pc.strength > player.strength {
                gameState.pcScore += 1
            }

            // Face-up for 3 seconds (count 5,4,3).
            if await !tick(3) { return }

            // Face-down for 2 seconds (count 2,1).
            gameState.cardsFaceUp = false
            if await !tick(2) { return }
        }

        if !Task.isCancelled {
            gameState.round = GameState.totalRounds
            gameState.endGame()
        }
    }

    // Counts down `seconds`, sleeping 1s each. Returns false if cancelled.
    private func tick(_ seconds: Int) async -> Bool {
        for _ in 0..<seconds {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
                return false
            }
            if Task.isCancelled { return false }
            secondsLeft = max(0, secondsLeft - 1)
        }
        return true
    }
}
