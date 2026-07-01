# CardBattle


Uploading Simulator Screen Recording - iPhone 17 Pro - 2026-07-01 at 10.46.32.mov…


A small UIKit + Storyboard iOS card game. The player is assigned to the **East** or **West** side based on their GPS longitude, then plays 10 automatic rounds of high-card against the PC.

Built to `IMPLEMENTATION_SPEC.md` — single `Main.storyboard`, no SwiftUI.

## Requirements

- Xcode 15 or newer (built and verified on Xcode 26).
- iOS 15.0+ simulator or device.

## How to run

1. Open `CardBattle.xcodeproj` in Xcode.
2. Choose an iOS Simulator (any iPhone, iOS 15+) and press **Run** (⌘R).
3. On first launch, tap **Insert Name** and allow the location permission prompt.
4. Once a name is set and a side is assigned, the **START** button appears — tap it to play.

### Testing the side assignment

The side comes from your longitude compared to the midpoint `34.817549168324334`:

| Longitude          | Side  |
|--------------------|-------|
| `> 34.8175…`       | East  |
| `≤ 34.8175…`       | West  |

In the Simulator set a custom location via **Features → Location → Custom Location…**:
- Longitude `35.0` → **East**
- Longitude `34.0` → **West**

## How to play

1. **Menu** — enter your name (persisted in `UserDefaults`) and wait for the location fix that assigns your side. START enables once both are set.
2. **Game** — 10 rounds run automatically at a 5-second cadence:
   - Both cards flip face-up for **3 seconds** (suit image + rank number shown).
   - Higher rank wins the round; a tie goes to the house (PC).
   - Cards flip face-down (red card back) for the remaining **2 seconds**, then the next round begins.
   - The running score for you and the PC is shown above the cards.
3. **Summary** — after round 10, the winner and their score are shown. Tie goes to the PC. Tap **Back to Menu** to play again.

## Orientation

The Game scene adapts to both orientations:
- **Portrait** — cards use a true playing-card ratio (height = 1.4 × width) at ~32% of the screen width.
- **Landscape** — card height is capped to half the safe-area height so the cards shrink and the name, round, and both score labels stay visible. The two cards stay centered around the mid-line.

## Project structure

```
CardBattle/
├─ Base.lproj/Main.storyboard   3 scenes (Menu, Game, Summary) in a UINavigationController
├─ Controllers/
│  ├─ MenuViewController.swift   name entry, location, START gating
│  ├─ GameViewController.swift   round loop, flip animation, scoring
│  └─ SummaryViewController.swift winner + unwind back to Menu
├─ State/GameState.swift         GameState.shared singleton (name, side, scores, round, tie rule)
├─ Location/LocationManager.swift one-shot CoreLocation fix
├─ Models/Card.swift             Side enum, Card struct, Deck (4 suits × ranks 1–13)
├─ Assets.xcassets/              Clubs, Diamonds, Hearts, Spade suits + CardBack (red back)
└─ Info.plist                    location usage key, scene manifest, bundle keys
```

Segues: `toGame` and `toSummary` (code-triggered `show`), `unwindToMenu` (unwind).

## Notes

- **Manual `Info.plist`** (`GENERATE_INFOPLIST_FILE = NO`) so the location usage string and scene manifest are explicit and version-controlled.
- **Round timing** uses nested non-repeating `Timer`s (3s face-up → flip → 2s face-down) so the flip animation is visible; the timer is invalidated in `viewWillDisappear`.
- **Tie rule** resolves to the PC, so the Summary never shows a draw.
- Bundle identifier: `com.afeka.CardBattle`.
