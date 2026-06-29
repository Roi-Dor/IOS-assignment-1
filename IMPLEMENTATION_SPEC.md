# iOS Card Battle — Implementation Spec

**Audience:** a coding agent implementing this app end-to-end.
**Goal:** deliver a complete, buildable iOS app that satisfies every requirement and acceptance criterion below. Do not ask the user questions — make the decisions specified here and note any assumptions in a short `NOTES.md`.

---

## 1. Summary

Build a small iOS game with **three screens** the player moves through in order:

1. **Menu** — player enters a name; the app reads GPS once and assigns the player to the **East** or **West** side based on a fixed longitude line; then a **START** button appears.
2. **Game** — runs automatically (no buttons). Over **10 rounds**, two cards flip on a timer; the stronger card scores a point each round.
3. **Summary** — shows the winner and final score, plus a **BACK TO MENU** button.

The game **cannot start without both a name and a location**.

---

## 2. Tech stack (required)

- **Language:** Swift 5.9+
- **UI:** SwiftUI (no Storyboards)
- **Min iOS target:** iOS 16.0
- **Location:** CoreLocation (`CLLocationManager`)
- **Architecture:** a single shared observable state object (`@StateObject` at the root, injected via `.environmentObject`).
- **Project name:** `CardBattle`
- **No third-party dependencies.** Standard library + Apple frameworks only.

Deliver a complete Xcode project that builds and runs in the iOS Simulator with **zero code changes required**.

---

## 3. Decisions already made (do not deviate)

- **East/West axis is LONGITUDE.** The brief's value `34.817549168324334` is a longitude. Compare the device's `longitude`:
  - `longitude > 34.817549168324334` → **East** side
  - otherwise → **West** side
  - Define this as a constant `let MIDPOINT_LONGITUDE = 34.817549168324334`.
- **Opponent name** is `"PC"`. The human player's name is what they typed.
- **Card flip cadence:** each round lasts **5 seconds**. Within a round, cards are **face-up for 3 seconds**, then **face-down for 2 seconds**, then the next round begins. New card images are chosen at the moment of each flip-up.
- **Rounds:** exactly **10**. After round 10 completes, auto-navigate to Summary.
- **Equal-strength round:** no points awarded to either side; the round still counts toward the 10.
- **Final tie:** the **house (PC) wins**. There must never be a displayed draw.
- **Persistence of name:** the player's name persists across app launches using `UserDefaults` (key: `"playerName"`). On first launch the field is empty and the "Insert name" button is shown; on later launches the saved name is shown in place of the button. The user may still edit it.

---

## 4. Data models

### `Card`
```swift
struct Card: Identifiable, Equatable {
    let id = UUID()
    let imageName: String   // SF Symbol name (see §7)
    let strength: Int       // 1...10
}
```

A static deck of at least 8 cards with varied strengths. Use **SF Symbols** for images so no image assets are needed (e.g. `flame.fill`=8, `bolt.fill`=7, `drop.fill`=4, `leaf.fill`=3, `snowflake`=5, `tornado`=9, `sun.max.fill`=6, `moon.fill`=2). Each round picks one random card per side independently.

### `Side`
```swift
enum Side { case east, west }
```

### `Screen`
```swift
enum Screen { case menu, game, summary }
```

---

## 5. Shared state — `GameState` (`ObservableObject`)

Holds all cross-screen state. Published properties:

- `screen: Screen` = `.menu`
- `playerName: String` (loaded from `UserDefaults`)
- `side: Side?` — `nil` until a location fix assigns it
- `playerSideLabel: String` — "East Side" / "West Side" derived from `side`
- `playerScore: Int`, `pcScore: Int`
- `round: Int` (0...10)
- card display state: `playerCard: Card?`, `pcCard: Card?`, `cardsFaceUp: Bool`

Methods:

- `assignSide(longitude: Double)` — sets `side` per §3.
- `setName(_:)` — sets `playerName`, writes to `UserDefaults`.
- `canStart: Bool` — `true` only when `!playerName.isEmpty && side != nil`.
- `startGame()` — resets scores/round, sets `screen = .game`.
- `endGame()` — sets `screen = .summary`.
- `resetToMenu()` — resets scores/round/cards, sets `screen = .menu` (keeps name + side).
- `winnerName: String` and `winnerScore: Int` — apply the house-wins tie rule.

---

## 6. Location — `LocationManager` (`NSObject, ObservableObject, CLLocationManagerDelegate`)

Behavior:

1. On `start()`: set delegate, call `requestWhenInUseAuthorization()`, then `requestLocation()`.
2. On `didUpdateLocations`: take the **first** location, publish its `coordinate.longitude`, then call `manager.stopUpdatingLocation()` (the brief explicitly requires stopping once a fix is received).
3. On `didFailWithError` or denied/restricted authorization: publish an `authError` flag/message so the Menu can show "Location permission needed — enable it in Settings."
4. Expose: `@Published var longitude: Double?`, `@Published var status: enum { idle, locating, done, denied }`.

**Info.plist:** add `NSLocationWhenInUseUsageDescription` = `"We use your location once to assign your side in the game."` Ensure this key is actually present in the built project (set it in the target's Info settings).

---

## 7. Screens (exact behavior)

### Screen 1 — Menu (`MenuView`)
Layout (top to bottom):
- Title area showing "West Side" and "East Side" labels.
- **Name slot:**
  - If `playerName` is empty → show an **"Insert name"** button that opens a text-entry alert/sheet; on submit, call `setName`.
  - If `playerName` is non-empty → show the name as text (tappable to edit).
- **Location/side status:**
  - While locating → show "Locating…" (a `ProgressView` is fine).
  - When assigned → show "You are on the **East Side**" / "West Side".
  - If denied → show the permission message.
- **START button:**
  - Hidden or disabled until `canStart == true`.
  - Tapping calls `startGame()`.
- On `onAppear`, call `locationManager.start()`. When `longitude` publishes, call `gameState.assignSide(longitude:)`.

### Screen 2 — Game (`GameView`)
- **No buttons.** Starts automatically on `onAppear`.
- Top: scoreboard showing player name + `playerScore` on their side, "PC" + `pcScore` on the other. Position the human's score on the side matching `gameState.side`.
- Center: two card views (player vs PC) plus a small countdown indicator (e.g. seconds within the round).
- **Round loop** (use a repeating `Timer` or an `async` task; cancel it in `onDisappear`):
  - At round start: pick a random `Card` for each side, set `cardsFaceUp = true` (animate a flip).
  - Compare strengths: higher strength → that side `+1`; equal → no points.
  - After **3s**, set `cardsFaceUp = false`.
  - After a total of **5s**, increment `round` and start the next round.
  - After round **10**, stop the timer and call `endGame()`.
- Use a flip animation (e.g. `rotation3DEffect` on the card) so the flip is visible.

### Screen 3 — Summary (`SummaryView`)
- Show **"Winner: <winnerName>"** and **"score: <winnerScore>"** (apply house-wins tie rule).
- A **BACK TO MENU** button calling `resetToMenu()`.

---

## 8. Root view

`ContentView` owns `@StateObject GameState` + `LocationManager`, injects them via `.environmentObject`, and renders the current screen with a `switch gameState.screen`. Use a transition/animation between screens if convenient, but a plain switch is acceptable.

---

## 9. Project / file structure

```
CardBattle/
├── CardBattleApp.swift        // @main, shows ContentView
├── ContentView.swift          // screen switch + env objects
├── Models/
│   ├── Card.swift
│   ├── Side.swift
│   └── Screen.swift
├── State/
│   └── GameState.swift
├── Location/
│   └── LocationManager.swift
├── Views/
│   ├── MenuView.swift
│   ├── GameView.swift
│   ├── SummaryView.swift
│   └── CardView.swift         // reusable flipping card
└── Info.plist (with NSLocationWhenInUseUsageDescription)
```

Provide the full `.xcodeproj` so it opens and runs directly.

---

## 10. Acceptance criteria (the build is done when ALL pass)

1. App builds and runs in the iOS Simulator with no edits.
2. First launch: "Insert name" button shown; entering a name replaces the button with the name; name persists after relaunch.
3. On launch the app requests location **once** and stops updates after the first fix.
4. With a simulated longitude **> 34.8175** the player is **East**; **< 34.8175** the player is **West** (verify both).
5. START is disabled/hidden until a name **and** a side both exist.
6. Game screen has **no buttons** and starts automatically.
7. Cards flip every 5s, are face-up ~3s, and a new image appears each flip.
8. Stronger card scores a point each round; equal cards score nothing; score updates live.
9. Exactly 10 rounds run, then the app auto-navigates to Summary.
10. Summary shows the winner + score; ties resolve to PC; never shows a draw.
11. BACK TO MENU returns to the Menu with scores/round reset.
12. `NSLocationWhenInUseUsageDescription` is present so the permission prompt appears.

---

## 11. Testing notes for the implementer

- In the running Simulator: **Features → Location → Custom Location…**, enter a coordinate to test each branch (e.g. longitude `35.0` → East, `34.0` → West).
- Verify the timer is cancelled on leaving the Game screen (no scoring continues in the background).
- Confirm the permission prompt actually appears on first run (clean install / reset the Simulator's permissions if needed).

---

## 12. Deliverables

- The complete `CardBattle` Xcode project (builds + runs).
- A short `NOTES.md` listing any assumptions made and how to run it.
