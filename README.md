# 🃏 Card Battle

A small iOS card game built with **SwiftUI**. The player enters a name, the app reads the GPS **once** to assign them to the **East** or **West** side, and then watches an automatic 10‑round duel of playing cards against the house (**PC**). The stronger card wins each round; the winner is shown on a summary screen.

---

## ✨ Features

- **Three‑screen flow:** Menu → Game → Summary.
- **GPS side assignment:** a single location fix decides East/West by longitude.
- **Real playing‑card suits:** Hearts ♥, Diamonds ♦, Spades ♠, Clubs ♣ — using custom suit artwork.
- **Full deck ranks:** `1…10 < J < Q < K < A`; higher rank wins the round.
- **Fully automatic game:** no buttons during play — cards flip on a timer over 10 rounds.
- **Live scoreboard** that follows the player's assigned side.
- **Orientation‑aware UI:** dedicated layouts for portrait and landscape.
- **Name persistence** across launches via `UserDefaults`.

---

## 🎮 How to play

1. **Menu** — tap **Insert name**, type your name, and allow location access. The app reads your GPS once and shows whether you're on the **East Side** or **West Side**. The **START** button appears only once a name *and* a side both exist.
2. **Game** — runs on its own. Each round (5 seconds):
   - Two cards flip **face‑up for 3 seconds**, then **face‑down for 2 seconds**.
   - The stronger card scores **+1**; equal ranks score nothing.
   - After **10 rounds** the app jumps to the summary automatically.
3. **Summary** — shows the **winner** and **final score**, with a **BACK TO MENU** button.

### Rules
- **Side assignment:** `longitude > 34.817549168324334` → **East**, otherwise → **West**.
- **Card strength:** higher rank wins; Ace is highest.
- **Ties:** an equal round awards no points but still counts. A final tie resolves to the house (**PC**) — there is never a displayed draw.

---

## 🛠 Tech stack

| | |
|---|---|
| **Language** | Swift 5 |
| **UI** | SwiftUI (no Storyboards) |
| **Min iOS** | 16.0 |
| **Location** | CoreLocation (`CLLocationManager`) |
| **Architecture** | Single shared `GameState` (`ObservableObject`) injected via `.environmentObject` |
| **Dependencies** | None — Apple frameworks only |

---

## 🚀 Getting started

1. Open **`CardBattle.xcodeproj`** in Xcode 16 (or newer).
2. Choose an iOS Simulator (iPhone, iOS 16+).
3. Press **Run** (⌘R). No code changes are required.

### Testing the East/West split
In the running Simulator: **Features → Location → Custom Location…**
- Longitude `35.0` → **East**
- Longitude `34.0` → **West**

To re‑test the first‑launch / permission flow, erase the simulator (**Device → Erase All Content and Settings**).

---

## 📁 Project structure

```
CardBattle/
├── CardBattleApp.swift        # @main entry point
├── ContentView.swift          # screen switch + environment objects
├── Models/
│   ├── Card.swift             # Card + Suit, the deck, rank labels
│   ├── Side.swift             # east / west
│   └── Screen.swift           # menu / game / summary
├── State/
│   └── GameState.swift        # shared observable game state
├── Location/
│   └── LocationManager.swift  # one-shot CoreLocation fix
├── Views/
│   ├── MenuView.swift         # name entry + side status + START
│   ├── GameView.swift         # automatic round loop (portrait + landscape)
│   ├── SummaryView.swift      # winner + score + BACK TO MENU
│   └── CardView.swift         # reusable flipping card
└── Assets.xcassets/           # suit artwork (Hearts, Diamonds, Spade, Clubs)
```

---

## 🔒 Permissions

The app requests **When In Use** location access on first launch to assign your side. The usage description is provided via the build setting `INFOPLIST_KEY_NSLocationWhenInUseUsageDescription`:

> "We use your location once to assign your side in the game."

Location updates are stopped immediately after the first fix.

---

## 📝 Notes

See [`NOTES.md`](NOTES.md) for implementation assumptions and the full spec in [`IMPLEMENTATION_SPEC.md`](IMPLEMENTATION_SPEC.md).
# IOS-assignment-1
