# Savora — Signup Flow (Flutter)

Premium, animated onboarding for the Savora cloud-kitchen app.

## What's included

| Screen | What it does |
|---|---|
| **Signup** | Brand intro + phone / Google / Apple auth options |
| **Phone entry** | Animated country-code field with focus glow |
| **OTP verify** | Custom 5-box code input, resend timer, success dialog |

### Animations baked in
- Living gradient-glow background (slow drifting warm blobs)
- Breathing logo badge with pulsing glow
- Staggered fade-and-rise entrance for every element
- Press-scale feedback on all buttons
- Continuous shine sweep across the primary button
- Soft fade + scale page transitions between screens
- Animated focus borders + glow on inputs
- Spring-in success dialog

## Run it

```bash
# 1. Create a fresh Flutter project (or use your existing one)
flutter create savora_app

# 2. Replace the generated lib/ folder and pubspec.yaml
#    with the files provided here

# 3. Install dependencies
flutter pub get

# 4. Run
flutter run
```

> The only external package is **google_fonts** (Playfair Display for the
> wordmark, Plus Jakarta Sans for UI). Everything else is pure Flutter — no
> assets required to demo.

## File structure

```
lib/
├── main.dart
├── theme/
│   ├── app_colors.dart      # brand palette
│   └── app_theme.dart       # Material 3 dark theme + fonts
├── widgets/
│   ├── animated_background.dart
│   ├── savora_badge.dart
│   ├── primary_button.dart
│   ├── social_button.dart
│   └── reveal.dart          # stagger helper + page transition
└── screens/
    ├── login_screen.dart
    ├── phone_entry_screen.dart
    └── otp_screen.dart
```

## Hooking up real auth later
Right now the Google/Apple buttons and OTP verification are stubbed. When
you're ready, drop your backend calls into:
- `login_screen.dart` → the login action
- `phone_entry_screen.dart` → `_continue()` (send code request)
- `otp_screen.dart` → `_verify()` (validate code, then route to home)
