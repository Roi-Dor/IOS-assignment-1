import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "trophy.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .foregroundColor(.yellow)

            Text("Winner: \(gameState.winnerName)")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)

            Text("score: \(gameState.winnerScore)")
                .font(.title2)

            Spacer()

            Button(action: { gameState.resetToMenu() }) {
                Text("BACK TO MENU")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
