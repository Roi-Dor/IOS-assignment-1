import SwiftUI

struct CardView: View {
    let card: Card?
    let faceUp: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(faceUp ? Color.white : Color.blue)
                .shadow(radius: 4)

            if faceUp, let card {
                let suitColor = card.suit.isRed ? Color.red : Color.black
                VStack(spacing: 12) {
                    Image(card.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    Text(card.rankLabel)
                        .font(.title).bold()
                        .foregroundColor(suitColor)
                }
            } else {
                Image(systemName: "questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
        }
        .frame(width: 130, height: 180)
        .rotation3DEffect(.degrees(faceUp ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.4), value: faceUp)
    }
}
