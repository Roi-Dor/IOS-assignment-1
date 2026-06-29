import SwiftUI

struct MenuView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var locationManager: LocationManager

    @State private var showingNameEntry = false
    @State private var nameDraft = ""

    var body: some View {
        VStack(spacing: 32) {
            // Title area
            HStack {
                sideLabel("West Side", active: gameState.side == .west)
                Spacer()
                sideLabel("East Side", active: gameState.side == .east)
            }
            .padding(.horizontal)

            Text("Card Battle")
                .font(.largeTitle).bold()

            // Name slot
            nameSlot

            // Location / side status
            locationStatus

            Spacer()

            // START button
            if gameState.canStart {
                Button(action: { gameState.startGame() }) {
                    Text("START")
                        .font(.title2).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .onAppear {
            locationManager.start()
        }
        .onChange(of: locationManager.longitude) { newValue in
            if let lon = newValue {
                gameState.assignSide(longitude: lon)
            }
        }
        .alert("Enter your name", isPresented: $showingNameEntry) {
            TextField("Name", text: $nameDraft)
            Button("Save") { gameState.setName(nameDraft) }
            Button("Cancel", role: .cancel) { }
        }
    }

    @ViewBuilder
    private var nameSlot: some View {
        if gameState.playerName.isEmpty {
            Button("Insert name") {
                nameDraft = ""
                showingNameEntry = true
            }
            .font(.title3)
            .buttonStyle(.borderedProminent)
        } else {
            Button {
                nameDraft = gameState.playerName
                showingNameEntry = true
            } label: {
                Text(gameState.playerName)
                    .font(.title2).bold()
                    .foregroundColor(.primary)
            }
        }
    }

    @ViewBuilder
    private var locationStatus: some View {
        switch locationManager.status {
        case .idle, .locating:
            HStack(spacing: 8) {
                ProgressView()
                Text("Locating…")
            }
        case .done:
            Text("You are on the \(gameState.playerSideLabel)")
                .font(.headline)
        case .denied:
            Text("Location permission needed — enable it in Settings.")
                .font(.subheadline)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
    }

    private func sideLabel(_ text: String, active: Bool) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(active ? .white : .secondary)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(active ? Color.blue : Color.clear)
            .cornerRadius(8)
    }
}
