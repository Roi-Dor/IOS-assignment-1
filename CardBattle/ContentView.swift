import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        Group {
            switch gameState.screen {
            case .menu:
                MenuView()
            case .game:
                GameView()
            case .summary:
                SummaryView()
            }
        }
        .animation(.default, value: gameState.screen)
        .environmentObject(gameState)
        .environmentObject(locationManager)
    }
}

#Preview {
    ContentView()
}
