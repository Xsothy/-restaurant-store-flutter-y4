#!/bin/bash

# Development Script for Restaurant Store Flutter App
# This script helps with common development tasks

echo "🍽️  Restaurant Store Flutter - Development Script"
echo "================================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Function to show menu
show_menu() {
    echo ""
    echo "Choose an option:"
    echo "1) Install dependencies"
    echo "2) Generate code (JSON serialization)"
    echo "3) Run app in debug mode"
    echo "4) Run app in release mode"
    echo "5) Run tests"
    echo "6) Analyze code"
    echo "7) Build APK"
    echo "8) Clean build cache"
    echo "9) Upgrade dependencies"
    echo "0) Exit"
    echo ""
}

# Function to install dependencies
install_deps() {
    echo "📦 Installing dependencies..."
    flutter pub get
    if [ $? -eq 0 ]; then
        echo "✅ Dependencies installed successfully"
    else
        echo "❌ Failed to install dependencies"
    fi
}

# Function to generate code
generate_code() {
    echo "🔧 Generating code (JSON serialization)..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    if [ $? -eq 0 ]; then
        echo "✅ Code generation completed successfully"
    else
        echo "❌ Code generation failed"
    fi
}

# Function to run app in debug mode
run_debug() {
    echo "🚀 Running app in debug mode..."
    flutter run
}

# Function to run app in release mode
run_release() {
    echo "🚀 Running app in release mode..."
    flutter run --release
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."
    flutter test
    if [ $? -eq 0 ]; then
        echo "✅ All tests passed"
    else
        echo "❌ Some tests failed"
    fi
}

# Function to analyze code
analyze_code() {
    echo "🔍 Analyzing code..."
    flutter analyze
    if [ $? -eq 0 ]; then
        echo "✅ Code analysis completed successfully"
    else
        echo "❌ Code analysis found issues"
    fi
}

# Function to build APK
build_apk() {
    echo "📱 Building APK..."
    flutter build apk --release
    if [ $? -eq 0 ]; then
        echo "✅ APK built successfully"
        echo "📁 APK location: build/app/outputs/flutter-apk/app-release.apk"
    else
        echo "❌ APK build failed"
    fi
}

# Function to clean build cache
clean_cache() {
    echo "🧹 Cleaning build cache..."
    flutter clean
    if [ $? -eq 0 ]; then
        echo "✅ Build cache cleaned successfully"
    else
        echo "❌ Failed to clean build cache"
    fi
}

# Function to upgrade dependencies
upgrade_deps() {
    echo "⬆️  Upgrading dependencies..."
    flutter pub upgrade
    if [ $? -eq 0 ]; then
        echo "✅ Dependencies upgraded successfully"
    else
        echo "❌ Failed to upgrade dependencies"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice (0-9): " choice
    
    case $choice in
        1)
            install_deps
            ;;
        2)
            generate_code
            ;;
        3)
            run_debug
            ;;
        4)
            run_release
            ;;
        5)
            run_tests
            ;;
        6)
            analyze_code
            ;;
        7)
            build_apk
            ;;
        8)
            clean_cache
            ;;
        9)
            upgrade_deps
            ;;
        0)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please enter a number between 0 and 9."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
