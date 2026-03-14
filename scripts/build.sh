#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILES_DIR="$ROOT_DIR/profiles"
OUT_DIR="$ROOT_DIR/generated"
PROFILE="${1:-}"
LANG="${2:-bi}"

case "$LANG" in
  es|en|bi|all) ;;
  *)
    echo "Invalid lang: $LANG (use es|en|bi|all)" >&2
    exit 1
    ;;
esac

mkdir -p "$OUT_DIR"

list_profiles() {
  find "$PROFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
    -exec test -f '{}/cv.json' \; \
    -exec test -f '{}/photo.jpg' \; \
    -printf '%f\n' | sort
}

build_one() {
  local profile_name="$1"
  local lang="$2"
  local profile_dir="$PROFILES_DIR/$profile_name"
  local target_dir="$OUT_DIR/$profile_name"
  local typ_name
  local pdf_name

  [[ -f "$profile_dir/cv.json" ]] || { echo "Missing $profile_dir/cv.json" >&2; exit 1; }
  [[ -f "$profile_dir/photo.jpg" ]] || { echo "Missing $profile_dir/photo.jpg" >&2; exit 1; }

  case "$lang" in
    bi)
      typ_name="cv.typ"
      pdf_name="cv.pdf"
      ;;
    es)
      typ_name="cv-es.typ"
      pdf_name="cv-es.pdf"
      ;;
    en)
      typ_name="cv-en.typ"
      pdf_name="cv-en.pdf"
      ;;
    *)
      echo "Invalid lang: $lang" >&2
      exit 1
      ;;
  esac

  mkdir -p "$target_dir"

  cat > "$target_dir/$typ_name" <<TYP
#import "../../templates/cv.typ": render
#render("../profiles/$profile_name", lang: "$lang")
TYP

  typst compile --root "$ROOT_DIR" "$target_dir/$typ_name" "$target_dir/$pdf_name"
}

if [[ -n "$PROFILE" ]]; then
  profiles=("$PROFILE")
else
  mapfile -t profiles < <(list_profiles)
fi

if [[ ${#profiles[@]} -eq 0 ]]; then
  echo "No profiles found in $PROFILES_DIR" >&2
  exit 1
fi

for p in "${profiles[@]}"; do
  if [[ ! -d "$PROFILES_DIR/$p" ]]; then
    echo "Profile not found: $p" >&2
    mapfile -t available_profiles < <(list_profiles)
    if [[ ${#available_profiles[@]} -gt 0 ]]; then
      echo "Available profiles: ${available_profiles[*]}" >&2
    fi
    exit 1
  fi

  if [[ ! -f "$PROFILES_DIR/$p/cv.json" || ! -f "$PROFILES_DIR/$p/photo.jpg" ]]; then
    echo "Invalid profile: $p (expected cv.json and photo.jpg)" >&2
    exit 1
  fi

  if [[ "$LANG" == "all" ]]; then
    build_one "$p" es
    build_one "$p" en
    build_one "$p" bi
  else
    build_one "$p" "$LANG"
  fi
done

echo "Generated cv.typ and cv.pdf files in $OUT_DIR"
