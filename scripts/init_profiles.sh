#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$ROOT_DIR/profiles"

if find "$ROOT_DIR/profiles" -mindepth 1 -maxdepth 1 -type d | read -r _; then
  echo "profiles/ already has profiles. Nothing to do."
  exit 0
fi

cp -r "$ROOT_DIR/profiles.example"/. "$ROOT_DIR/profiles/"
echo "Initialized profiles/ from profiles.example/"
echo "Edit each profiles/<name>/cv.json and replace profiles/<name>/photo.jpg"
