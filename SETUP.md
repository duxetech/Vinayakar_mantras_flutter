# Vinayagar Mantras App Setup

This Flutter app has been created with two main sections:

## Features

### 1. Chapters Tab
- Displays a list of Vinayagar (Ganesha) mantras and their meanings
- Click on any chapter to view the full detailed text
- Includes mantras like Vakratunda Mahakaya, Gajananam, Ganesha Gayatri, etc.

### 2. Audio Tab
- Lists offline audio songs/chants
- Click on any song to play it
- Full audio player controls:
  - Play/Pause
  - Seek bar to jump to any position
  - Skip forward/backward 10 seconds
  - Shows current position and total duration
  - Visual indicator for currently playing song

## Setup Instructions

### 1. Install Dependencies
Run the following command to install the required packages:
```bash
flutter pub get
```

### 2. Add Audio Files
To use the audio playback feature, you need to add audio files:

1. Place your MP3/audio files in the `assets/audio/` folder
2. Update the file paths in `lib/data/audio_data.dart` to match your actual file names

Example audio files expected:
- `assets/audio/vakratunda.mp3`
- `assets/audio/gajananam.mp3`
- `assets/audio/gayatri.mp3`
- `assets/audio/om_gam.mp3`
- `assets/audio/ashtottara.mp3`

**Note:** The app will show an error if you try to play audio without actual files. Either:
- Add real audio files with the names above, OR
- Update the file names in `lib/data/audio_data.dart` to match your files

### 3. Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── chapter.dart              # Chapter data model
│   └── audio_song.dart           # Audio song data model
├── data/
│   ├── chapters_data.dart        # Chapter content
│   └── audio_data.dart           # Audio songs list
└── screens/
    ├── home_screen.dart          # Main screen with tabs
    ├── chapters_tab.dart         # Chapters list view
    ├── chapter_detail_screen.dart # Chapter detail view
    └── audio_tab.dart            # Audio player screen
```

## Dependencies Used

- `just_audio: ^0.9.40` - For audio playback functionality

## Customization

### Adding More Chapters
Edit `lib/data/chapters_data.dart` and add new `Chapter` objects to the list.

### Adding More Audio Songs
1. Add the audio file to `assets/audio/`
2. Edit `lib/data/audio_data.dart` and add new `AudioSong` objects to the list

### Changing Theme Colors
Edit the `ThemeData` in `lib/main.dart` to customize colors.
