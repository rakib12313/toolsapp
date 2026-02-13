# ToolBox Pro

A comprehensive multimedia toolkit app for Android and Windows built with Flutter.

## Features

### Image Tools
- **Image Resizer** - Resize images by percentage or dimensions
- **Image Compressor** - Compress images to reduce file size
- **Image Converter** - Convert images between formats (PNG, JPG, WEBP)
- **Images to PDF** - Convert multiple images to a single PDF

### PDF Tools
- **PDF Merger** - Merge multiple PDF files into one
- **PDF to Images** - Convert PDF pages to image files
- **PDF Editor** - Rearrange, rotate, or delete PDF pages

### Video Tools
- **Video Converter** - Convert videos between formats
- **Video Compressor** - Reduce video file size with CRF compression
- **Video Trimmer** - Trim video start and end points

### Audio Tools
- **Audio Extractor** - Extract audio from video files

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android SDK (API 21+)
- Windows 10+ (for Windows builds)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/toolbox_pro.git
cd toolbox_pro
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
# For Android
flutter run

# For Windows
flutter run -d windows
```

### Building

```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release

# Build Windows executable
flutter build windows --release
```

## Architecture

The app follows clean architecture principles with:
- **Presentation Layer**: UI widgets and screens
- **Business Logic Layer**: Providers for state management
- **Data Layer**: Services for storage and processing

## Dependencies

- `provider` - State management
- `sqflite` - Local database for history
- `shared_preferences` - Local settings storage
- `ffmpeg_kit_flutter` - Media processing
- `image` - Image manipulation
- `pdf` - PDF operations
- `file_picker` - File selection
- `permission_handler` - Runtime permissions

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.