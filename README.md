# Turf11 — Flutter App

Cricket & sports turf booking app built with Flutter 3.x (latest).

## Project Structure

```
turf11/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── theme/
│   │   └── app_theme.dart           # Colors, typography, theme
│   ├── widgets/
│   │   ├── shared_widgets.dart      # AppButton, BackRow, Badge, Card, etc.
│   │   └── bottom_nav.dart          # Bottom navigation bar
│   └── screens/
│       ├── splash_screen.dart       # Splash / onboarding
│       ├── login_screen.dart        # Login, OTP, Register
│       ├── home_screen.dart         # Home dashboard
│       └── turf_list_screen.dart    # Turfs, Booking, Join Match,
│                                    # Create Match, Wallet, Tournament,
│                                    # Notifications, Profile
└── pubspec.yaml
```

## Screens Included

| Screen | File |
|---|---|
| Splash | splash_screen.dart |
| Login (OTP) | login_screen.dart |
| OTP Verify | login_screen.dart |
| Register | login_screen.dart |
| Home | home_screen.dart |
| Turf List | turf_list_screen.dart |
| Book Slot | turf_list_screen.dart (BookingScreen) |
| Join Match | turf_list_screen.dart (JoinMatchScreen) |
| Create Match | turf_list_screen.dart (CreateMatchScreen) |
| Wallet/Recharge | turf_list_screen.dart (WalletScreen) |
| Tournaments | turf_list_screen.dart (TournamentScreen) |
| Notifications | turf_list_screen.dart (NotificationsScreen) |
| Profile | turf_list_screen.dart (ProfileScreen) |

## Design System

**Colors** (`AppColors`)
- `dark` → #1C1C14 (primary dark)
- `green` → #3D6B35 (brand green)
- `greenLt` → #D6E8D2 (light green)
- `muted` → #7A7A68
- `bg` → #E8E4DC (background)

**Typography** — DM Sans (Google Fonts)

**Components**
- `AppButton` — primary/outline with optional trailing icon
- `AppCard` / `SmallCard` — elevated containers
- `AppBadge` — green / dark / amber / red variants
- `ChipRow` — single-select filter chips
- `ToggleRow` — labeled switch
- `SearchBar` — styled search input
- `AppAvatar` — initials avatar
- `AppProgress` — linear progress bar
- `PlayerDot` — match player slot indicators
- `TurfFieldBanner` — cricket field SVG banner
- `AppBottomNav` — 5-tab bottom navigation
- `BackRow` — back button row
- `SectionLabel` — uppercase section headers

## Setup

### Prerequisites
- Flutter SDK >= 3.3.0
- Dart >= 3.3.0

### Install & Run

```bash
cd turf11
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

## Dependencies

| Package | Purpose |
|---|---|
| `google_fonts` | DM Sans font |
| `lucide_icons` | Linear icon set |
| `go_router` | Navigation (ready to plug in) |
| `provider` | State management (ready to plug in) |
| `smooth_page_indicator` | Dot indicators |
| `flutter_svg` | SVG support |
| `intl` | Date formatting |

## Navigation Flow

```
SplashScreen
    └── LoginScreen
            ├── OtpScreen → HomeScreen
            └── RegisterScreen → HomeScreen

HomeScreen (BottomNav)
    ├── [0] Home
    │     ├── → TurfListScreen
    │     ├── → JoinMatchScreen
    │     ├── → CreateMatchScreen
    │     ├── → WalletScreen
    │     └── → TournamentScreen
    ├── [1] TurfListScreen → BookingScreen
    ├── [2] TournamentScreen
    ├── [3] NotificationsScreen
    └── [4] ProfileScreen → WalletScreen
```

## Adding State Management

The app is structured for easy Provider integration:

```dart
// In main.dart, wrap with MultiProvider:
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => WalletProvider()),
    ChangeNotifierProvider(create: (_) => MatchProvider()),
  ],
  child: const Turf11App(),
)
```

## API Integration Points

Each screen is ready for real API calls:
- `LoginScreen` → POST `/auth/send-otp`
- `OtpScreen` → POST `/auth/verify-otp`
- `TurfListScreen` → GET `/turfs?lat=&lng=`
- `BookingScreen` → POST `/bookings`
- `WalletScreen` → GET `/wallet`, POST `/wallet/recharge`
- `TournamentScreen` → GET `/tournaments`
