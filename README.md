# Audio Message Player

Audio Message Player is a macOS application designed to display and play all audio messages from the Messages app on your Mac. The native macOS Messages app does not provide a way to view or manage audio messages directly, and this app fills that gap.

## Features
- Displays all audio messages from the Messages app in a user-friendly interface.
- Allows playback of audio messages with play, pause, and scrubber controls.
- Supports viewing  file name and date metadata.
- Context menu option to open audio files in Finder.
- Fully written in Objective-C and compatible with macOS 11 (Big Sur) and later

---

## Installation Instructions

### **For Users**
1. **Download the App**:
   - Download the release build of Audio Message Player from the releases section and copy it into your Applications folder

2. **Enable Full Disk Access**:
   - Go to `System Settings` -> `Privacy & Security` -> `Full Disk Access`.
   - Turn on Full Disk Access for **Audio Message Player**. This permission is necessary for the app to access Messages data.

3. **Run the App**:
   - Open the app, and you can now view and play all your audio messages.

---

### **For Developers**
1. **Clone the Repository**:
   - Clone or download the source code of Audio Message Player from the repository.

2. **Open in Xcode**:
   - Open the `.xcodeproj` file in Xcode.

3. **Build and Run**:
   - Build and run the project using Xcode.

4. **Enable Full Disk Access**:
   - Go to `System Settings` -> `Privacy & Security` -> `Full Disk Access`.
   - Turn on Full Disk Access for the built application.

---

## License
© 2024 Ryan Nair. MIT License

---

## Notes
- Full Disk Access is required for the app to function properly as it needs access to Messages data.
- For any issues or feature requests, please file an issue or pull request.