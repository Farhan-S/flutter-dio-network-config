#!/bin/bash

echo "📦 Getting dependencies for all packages..."

# Get dependencies for all packages
for dir in packages/*/; do
  if [ -f "$dir/pubspec.yaml" ]; then
    package_name=$(basename "$dir")
    echo "  ▸ $package_name"
    (cd "$dir" && dart pub get > /dev/null 2>&1)
    if [ $? -eq 0 ]; then
      echo "    ✓ Dependencies installed"
    else
      echo "    ✗ Failed to install dependencies"
    fi
  fi
done

# Get dependencies for CLI
if [ -f "cli/pubspec.yaml" ]; then
  echo "  ▸ cli"
  (cd cli && dart pub get > /dev/null 2>&1)
  if [ $? -eq 0 ]; then
    echo "    ✓ Dependencies installed"
  else
    echo "    ✗ Failed to install dependencies"
  fi
fi

echo ""
echo "✨ All packages bootstrapped successfully!"
