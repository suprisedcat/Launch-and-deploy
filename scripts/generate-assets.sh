#!/bin/bash

# Asset Generation Script for React Native Expo Apps
# Generates app icons and splash screens from source images
#
# Prerequisites:
# - ImageMagick installed: brew install imagemagick
# - Source image (1024x1024px) for icon
# - Source image (2048x2732px) for splash screen
#
# Usage:
# ./scripts/generate-assets.sh path/to/icon.png path/to/splash.png

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "  React Native Asset Generator"
echo "  For Expo SDK 57 Apps"
echo "================================================"
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}ERROR: ImageMagick is not installed${NC}"
    echo "Install it with: brew install imagemagick"
    exit 1
fi

# Check arguments
if [ "$#" -lt 1 ]; then
    echo -e "${YELLOW}Usage: $0 <source-icon.png> [source-splash.png]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 my-icon.png"
    echo "  $0 my-icon.png my-splash.png"
    echo ""
    exit 1
fi

SOURCE_ICON=$1
SOURCE_SPLASH=$2

# Create assets directory if it doesn't exist
mkdir -p assets

echo -e "${GREEN}Step 1: Generating App Icon${NC}"
echo "Source: $SOURCE_ICON"

# Validate source icon
if [ ! -f "$SOURCE_ICON" ]; then
    echo -e "${RED}ERROR: Source icon file not found: $SOURCE_ICON${NC}"
    exit 1
fi

# Check icon dimensions
ICON_WIDTH=$(identify -format "%w" "$SOURCE_ICON")
ICON_HEIGHT=$(identify -format "%h" "$SOURCE_ICON")

if [ "$ICON_WIDTH" != "1024" ] || [ "$ICON_HEIGHT" != "1024" ]; then
    echo -e "${YELLOW}WARNING: Icon is ${ICON_WIDTH}x${ICON_HEIGHT}px, expected 1024x1024px${NC}"
    echo "Resizing to 1024x1024px..."
fi

# Generate app icon (1024x1024)
echo "Generating icon.png (1024x1024)..."
convert "$SOURCE_ICON" -resize 1024x1024 -background transparent -gravity center -extent 1024x1024 assets/icon.png

# Generate adaptive icon (1024x1024)
echo "Generating adaptive-icon.png (1024x1024)..."
convert "$SOURCE_ICON" -resize 1024x1024 -background transparent -gravity center -extent 1024x1024 assets/adaptive-icon.png

echo -e "${GREEN}✓ App icons generated successfully${NC}"
echo ""

# Generate splash screen if source provided
if [ -n "$SOURCE_SPLASH" ]; then
    echo -e "${GREEN}Step 2: Generating Splash Screen${NC}"
    echo "Source: $SOURCE_SPLASH"

    # Validate source splash
    if [ ! -f "$SOURCE_SPLASH" ]; then
        echo -e "${RED}ERROR: Source splash file not found: $SOURCE_SPLASH${NC}"
        exit 1
    fi

    # Check splash dimensions
    SPLASH_WIDTH=$(identify -format "%w" "$SOURCE_SPLASH")
    SPLASH_HEIGHT=$(identify -format "%h" "$SOURCE_SPLASH")

    if [ "$SPLASH_WIDTH" != "2048" ] || [ "$SPLASH_HEIGHT" != "2732" ]; then
        echo -e "${YELLOW}WARNING: Splash is ${SPLASH_WIDTH}x${SPLASH_HEIGHT}px, expected 2048x2732px${NC}"
        echo "Resizing to 2048x2732px..."
    fi

    # Generate splash screen (2048x2732 - iPad Pro 12.9")
    echo "Generating splash.png (2048x2732)..."
    convert "$SOURCE_SPLASH" -resize 2048x2732 -gravity center -extent 2048x2732 assets/splash.png

    echo -e "${GREEN}✓ Splash screen generated successfully${NC}"
    echo ""
else
    echo -e "${YELLOW}Step 2: Skipping splash screen (no source provided)${NC}"
    echo "To generate splash screen, run:"
    echo "  $0 $SOURCE_ICON path/to/splash.png"
    echo ""
fi

# Summary
echo "================================================"
echo -e "${GREEN}Asset Generation Complete!${NC}"
echo "================================================"
echo ""
echo "Generated files:"
echo "  ✓ assets/icon.png (1024x1024)"
echo "  ✓ assets/adaptive-icon.png (1024x1024)"

if [ -n "$SOURCE_SPLASH" ]; then
    echo "  ✓ assets/splash.png (2048x2732)"
fi

echo ""
echo "Next steps:"
echo "  1. Review generated assets"
echo "  2. Update app.json with asset paths (already configured)"
echo "  3. Test app with: npx expo start"
echo "  4. Build for production: eas build --profile production"
echo ""

# Optional: Generate iOS and Android specific sizes
echo -e "${YELLOW}Optional: Generate additional platform-specific sizes?${NC}"
echo "This will create iOS and Android launcher icons in various sizes."
read -p "Generate? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${GREEN}Generating iOS icon sizes...${NC}"

    mkdir -p assets/ios

    # iOS icon sizes
    convert assets/icon.png -resize 20x20 assets/ios/icon-20.png
    convert assets/icon.png -resize 29x29 assets/ios/icon-29.png
    convert assets/icon.png -resize 40x40 assets/ios/icon-40.png
    convert assets/icon.png -resize 58x58 assets/ios/icon-58.png
    convert assets/icon.png -resize 60x60 assets/ios/icon-60.png
    convert assets/icon.png -resize 76x76 assets/ios/icon-76.png
    convert assets/icon.png -resize 80x80 assets/ios/icon-80.png
    convert assets/icon.png -resize 87x87 assets/ios/icon-87.png
    convert assets/icon.png -resize 120x120 assets/ios/icon-120.png
    convert assets/icon.png -resize 152x152 assets/ios/icon-152.png
    convert assets/icon.png -resize 167x167 assets/ios/icon-167.png
    convert assets/icon.png -resize 180x180 assets/ios/icon-180.png
    convert assets/icon.png -resize 1024x1024 assets/ios/icon-1024.png

    echo -e "${GREEN}✓ iOS icons generated in assets/ios/${NC}"
    echo ""

    echo -e "${GREEN}Generating Android icon sizes...${NC}"

    mkdir -p assets/android

    # Android icon sizes
    convert assets/icon.png -resize 36x36 assets/android/mdpi.png
    convert assets/icon.png -resize 48x48 assets/android/hdpi.png
    convert assets/icon.png -resize 72x72 assets/android/xhdpi.png
    convert assets/icon.png -resize 96x96 assets/android/xxhdpi.png
    convert assets/icon.png -resize 144x144 assets/android/xxxhdpi.png
    convert assets/icon.png -resize 192x192 assets/android/icon-192.png
    convert assets/icon.png -resize 512x512 assets/android/icon-512.png

    echo -e "${GREEN}✓ Android icons generated in assets/android/${NC}"
    echo ""

    echo "Platform-specific icons are optional for Expo apps."
    echo "Expo handles icon generation automatically from icon.png and adaptive-icon.png."
    echo ""
fi

echo -e "${GREEN}All done! 🎉${NC}"
echo ""

exit 0
