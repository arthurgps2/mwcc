#!/bin/bash
set -e  # Equivalent to $ErrorActionPreference = "Stop"

OUTFOLDER="pack"

# Remove existing pack folder if it exists
rm -rf "$OUTFOLDER"

# Create fresh pack directory
mkdir -p "$OUTFOLDER"

# Copy files excluding specified patterns (equivalent to robocopy filters)
rsync -av --exclude='pack' \
      --exclude='.*' \
      --exclude='.gitignore' \
      --exclude='*.md' \
      --exclude='*.ps1' \
      --exclude='*.gma' \
      --exclude='*license.txt' \
      --exclude='package.sh' \
      --exclude='publish.sh' \
      ./ "$OUTFOLDER/"

# Create the GMA package
../../../bin/gmad_linux create -folder "$OUTFOLDER" -out "packed.gma"
