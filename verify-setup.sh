#!/bin/bash

# Activity 20 Setup Verification Script
# Checks if all requirements are met before deployment

# No `set -e`: a failed check must be counted and reported, not stop the script.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "================================================"
echo "  Activity 20: Deploy Ready"
echo "  Setup Verification"
echo "================================================"
echo ""

ERRORS=0
WARNINGS=0

# Function to check command exists
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $2 installed"
        return 0
    else
        echo -e "${RED}✗${NC} $2 not found"
        echo "  Install with: $3"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to report an optional tool (never counts as an error)
check_optional() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $2 installed"
    else
        echo -e "${YELLOW}-${NC} $2 not found (optional)"
        echo "  Install with: $3"
    fi
}

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $2 missing"
        echo "  Expected at: $1"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check file size
check_file_size() {
    if [ -f "$1" ]; then
        SIZE=$(stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null)
        if [ "$SIZE" -gt 1000 ]; then
            echo -e "${GREEN}✓${NC} $2 has content (${SIZE} bytes)"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} $2 seems empty or placeholder"
            echo "  Size: ${SIZE} bytes (expected >1KB)"
            WARNINGS=$((WARNINGS + 1))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} $2 not found"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check JSON field
check_json_field() {
    VALUE=$(node -p "try { require('./$1').$2 } catch(e) { '' }" 2>/dev/null)
    if [ -n "$VALUE" ] && [ "$VALUE" != "undefined" ]; then
        if [[ "$VALUE" == *"yourcompany"* ]] || [[ "$VALUE" == *"yourname"* ]] || [[ "$VALUE" == *"Your"* ]] \
            || [[ "$VALUE" == *"My Mobile App"* ]] || [[ "$VALUE" == *"my-mobile-app"* ]] || [[ "$VALUE" == *"my-portfolio"* ]]; then
            echo -e "${YELLOW}⚠${NC} $3: \"$VALUE\" (needs customization)"
            WARNINGS=$((WARNINGS + 1))
            return 1
        else
            echo -e "${GREEN}✓${NC} $3: \"$VALUE\""
            return 0
        fi
    else
        echo -e "${RED}✗${NC} $3 not set in $1"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

echo -e "${BLUE}═══ System Requirements ═══${NC}"
echo ""

check_command "node" "Node.js" "Download from https://nodejs.org"
check_command "npm" "npm" "Comes with Node.js"
check_command "git" "Git" "Download from https://git-scm.com"

echo ""
echo -e "${BLUE}═══ Expo Tools ═══${NC}"
echo ""

check_command "eas" "EAS CLI" "npm install -g eas-cli"

# Check EAS login
if command -v eas &> /dev/null; then
    EAS_USER=$(eas whoami 2>/dev/null || echo "")
    if [ -n "$EAS_USER" ] && [ "$EAS_USER" != "Not logged in" ]; then
        echo -e "${GREEN}✓${NC} Logged into Expo as: $EAS_USER"
    else
        echo -e "${YELLOW}⚠${NC} Not logged into Expo"
        echo "  Run: eas login"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

echo ""
echo -e "${BLUE}═══ Project Files ═══${NC}"
echo ""

check_file "package.json" "package.json"
check_file "app.json" "app.json"
check_file "eas.json" "eas.json"
check_file "App.js" "App.js"

echo ""
echo -e "${BLUE}═══ README ═══${NC}"
echo ""

check_file "README.md" "README.md"

echo ""
echo -e "${BLUE}═══ TODO #1: Assets ═══${NC}"
echo ""

check_file_size "assets/icon.png" "App icon (icon.png)"
check_file_size "assets/splash.png" "Splash screen (splash.png)"
check_file_size "assets/adaptive-icon.png" "Adaptive icon (adaptive-icon.png)"

# Check if assets are still templates (M1 text)
if [ -f "assets/icon.png" ]; then
    if file assets/icon.png | grep -q "PNG"; then
        echo -e "${GREEN}✓${NC} Icon is valid PNG format"
    else
        echo -e "${YELLOW}⚠${NC} Icon may not be valid PNG"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

echo ""
echo -e "${BLUE}═══ TODO #2: Configuration ═══${NC}"
echo ""

if [ -f "app.json" ]; then
    check_json_field "app.json" "expo.name" "App name"
    check_json_field "app.json" "expo.slug" "App slug"
    check_json_field "app.json" "expo.version" "Version"
    check_json_field "app.json" "expo.ios.bundleIdentifier" "iOS bundle ID"
    check_json_field "app.json" "expo.android.package" "Android package"

    # Check if project ID is set
    PROJECT_ID=$(node -p "try { require('./app.json').expo.extra.eas.projectId } catch(e) { '' }" 2>/dev/null)
    if [ -n "$PROJECT_ID" ] && [[ "$PROJECT_ID" != *"YOUR_"* ]] && [[ "$PROJECT_ID" != *"your-project-id"* ]]; then
        echo -e "${GREEN}✓${NC} EAS project ID configured"
    else
        echo -e "${YELLOW}⚠${NC} EAS project not configured yet"
        echo "  Run: eas build:configure"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

echo ""
echo -e "${BLUE}═══ Dependencies ═══${NC}"
echo ""

if [ -d "node_modules" ]; then
    echo -e "${GREEN}✓${NC} node_modules installed"

    # Check key dependencies
    if [ -d "node_modules/expo" ]; then
        EXPO_VERSION=$(node -p "require('./node_modules/expo/package.json').version" 2>/dev/null)
        echo -e "${GREEN}✓${NC} Expo SDK installed (v$EXPO_VERSION)"
    fi

    if [ -d "node_modules/react" ]; then
        REACT_VERSION=$(node -p "require('./node_modules/react/package.json').version" 2>/dev/null)
        echo -e "${GREEN}✓${NC} React installed (v$REACT_VERSION)"
    fi

    if [ -d "node_modules/react-native" ]; then
        RN_VERSION=$(node -p "require('./node_modules/react-native/package.json').version" 2>/dev/null)
        echo -e "${GREEN}✓${NC} React Native installed (v$RN_VERSION)"
    fi
else
    echo -e "${YELLOW}⚠${NC} node_modules not installed"
    echo "  Run: npm install --legacy-peer-deps"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo -e "${BLUE}═══ Optional Tools ═══${NC}"
echo ""

check_optional "convert" "ImageMagick" "brew install imagemagick (for asset generation)"

echo ""
echo "================================================"
echo "  Verification Summary"
echo "================================================"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! You're ready to deploy.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Complete TODO #1: Create app assets"
    echo "  2. Complete TODO #2: Configure app.json"
    echo "  3. Complete TODO #3: Build and submit"
    echo ""
    echo "See README.md for detailed instructions."
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Setup complete with $WARNINGS warning(s).${NC}"
    echo ""
    echo "Warnings are usually about incomplete TODOs."
    echo "Review the warnings above and complete TODOs as needed."
else
    echo -e "${RED}✗ Setup incomplete. Found $ERRORS error(s) and $WARNINGS warning(s).${NC}"
    echo ""
    echo "Please address the errors above before proceeding."
    echo ""
    echo "Quick fixes:"
    echo "  - Install missing tools (Node.js, EAS CLI, etc.)"
    echo "  - Run: npm install --legacy-peer-deps"
    echo "  - Run: eas login"
    echo "  - Run: eas build:configure"
fi

echo ""

exit $ERRORS
