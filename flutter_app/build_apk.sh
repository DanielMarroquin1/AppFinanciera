#!/bin/bash
# Script to auto-increment version and build APK for QUIVO

PUBSPEC_FILE="pubspec.yaml"
SETTINGS_FILE="lib/presentation/screens/settings_screen.dart"

# Extract current version from pubspec (e.g. version: 1.0.0+1)
CURRENT_VER=$(grep "^version: " $PUBSPEC_FILE | awk '{print $2}')
BASE_VER=$(echo $CURRENT_VER | cut -d'+' -f1)
BUILD_NUM=$(echo $CURRENT_VER | cut -d'+' -f2)

# Split base version (e.g. 1.0.0 -> 1, 0, 0)
IFS='.' read -r v1 v2 v3 <<< "$BASE_VER"

# Increment minor version (v2) for this rule: 1.0 -> 1.1 -> 1.2
# Or just increment v2 directly. Assuming format is 1.X.Y
NEW_V2=$((v2 + 1))
NEW_BASE_VER="$v1.$NEW_V2.0"
NEW_BUILD_NUM=$((BUILD_NUM + 1))
NEW_VER="$NEW_BASE_VER+$NEW_BUILD_NUM"

# Update pubspec.yaml
sed -i '' "s/^version: .*/version: $NEW_VER/" $PUBSPEC_FILE

# Update settings_screen.dart text (e.g. "Versión 1.X de QUIVO")
sed -i '' -E "s/Text\('Versión [0-9]+\.[0-9]+.* de QUIVO'/Text\('Versión $v1.$NEW_V2 de QUIVO'/" $SETTINGS_FILE

echo "=========================================="
echo "Versión actualizada de $BASE_VER a $NEW_BASE_VER"
echo "Generando APK..."
echo "=========================================="

flutter build apk

echo "=========================================="
echo "APK generado con éxito. Versión actual: $NEW_BASE_VER"
echo "=========================================="
