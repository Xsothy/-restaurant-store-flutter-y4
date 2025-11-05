# Assets Directory

This directory contains all the static assets for the Flutter application.

## Directory Structure

- `images/` - Image assets (PNG, JPG, etc.)
- `animations/` - Lottie animation files
- `icons/` - App icons and small icons
- `fonts/` - Custom font files

## Image Assets

Add your app images here and reference them in `pubspec.yaml`.

## Animations

Add Lottie animation files (.json) here for smooth animations.

## Icons

- App icons should be placed here
- Small UI icons can also be stored here

## Fonts

Custom font files (.ttf, .otf) should be placed here and configured in `pubspec.yaml`.

## Usage

To use assets in your Flutter code:

```dart
// Images
Image.asset('assets/images/your_image.png')

// Animations
Lottie.asset('assets/animations/your_animation.json')

// Fonts
Text(
  'Hello World',
  style: TextStyle(fontFamily: 'YourFont'),
)
```
