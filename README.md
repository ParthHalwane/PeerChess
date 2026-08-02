# ♟️ PeerChess

**PeerChess** is a feature-packed, offline 2-player P2P (Peer-to-Peer) Chess application built with Flutter. It allows two players in physical proximity (e.g., in a train, cafe, or park) to connect wirelessly and play high-precision chess with **zero internet or cellular data required**!

---

## 🚀 Download Release APK

📥 **[Download Latest PeerChess APK](PeerChess.apk)**  
*File Name*: `PeerChess.apk`

---

## ✨ Features

- 📡 **Offline Peer-to-Peer Wireless Discovery**: Uses **Google Nearby Connections API** (Bluetooth LE + Wi-Fi Direct) for local device discovery and low-latency pairing without routers or internet.
- ⏱️ **High-Precision Chess Clocks**: Bullet (1m), Blitz (3m/5m), Rapid (10m/15m) presets with millisecond accuracy, delay/increment support, and network latency compensation.
- 🎨 **Crisp Vector Chess Graphics**: Built with `chess_vectors_flutter` SVG vector pieces and smooth 60 FPS board move transitions (`AnimatedContainer`).
- 🔄 **Instant Rematch ("Play Again")**: Send and accept rematch requests right from the game over screen with color swapping and zero setup hassle.
- 🤝 **Interactive Draw & Resign System**: Non-intrusive top banner notifications for draw offers and confirmation dialogs for accidental resign protection.
- 📜 **Offline Game History & PGN Export**: Saves completed games locally in SQLite with full PGN move history.
- 🤖 **Play vs Offline AI**: Practice offline against a built-in chess engine bot.
- 🌓 **Custom Board Themes**: Standard, Wood, Dark, and Neon Cyberpunk themes with sound effects and haptic vibration feedback.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (`flutter_riverpod`)
- **P2P Networking**: `nearby_connections` (Star Topology, `com.peerchess.app.peer_chess`)
- **Chess Engine Logic**: `chess` (SAN/UCI validation & FEN state generation)
- **Vector Graphics**: `chess_vectors_flutter`
- **Database**: SQLite (`sqflite` & `path`)
- **Utilities**: `permission_handler`, `wakelock_plus`, `vibration`, `flutter_animate`

---

## 📱 How to Play (P2P Mode)

1. Ensure **Bluetooth**, **Wi-Fi**, and **Location (GPS)** are toggled **ON** on both physical Android phones.
2. Launch **PeerChess** on both phones.
3. Player 1: Tap **Host Game** (starts broadcasting).
4. Player 2: Tap **Join Game** (scans for nearby hosts).
5. Tap **Join** when Player 1's name appears on screen!

---

## 🧪 Verification & Testing

Run unit tests locally:
```bash
flutter test
```

Build release APK:
```bash
flutter build apk --release
```

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for details.
