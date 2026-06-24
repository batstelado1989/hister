#!/bin/sh

set -eu

DATASETS="go-stdlib mdn-css mdn-html mdn-js powershell"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ -f "$SCRIPT_DIR/../config.yml" ]; then
  cd "$SCRIPT_DIR/.."
fi

if [ -n "${HISTER:-}" ]; then
  :
elif [ -x ./hister ]; then
  HISTER=./hister
elif [ -x "$SCRIPT_DIR/../hister" ]; then
  HISTER=$SCRIPT_DIR/../hister
else
  HISTER=hister
fi

print_options() {
  printf 'Usage: %s DATASET\n\n' "$0"
  printf 'Datasets:\n'
  for dataset in $DATASETS; do
    printf '  %s\n' "$dataset"
  done
  printf '  all\n'
}

export_dataset() {
  dataset=$1
  label=$2

  "$HISTER" export "$dataset.json" "label:$label"
}

fetch_go_stdlib() {
  label=golang

  "$HISTER" index --recursive \
    --allowed-pattern="^https://pkg\.go\.dev/.+@go1\.26\.4$" \
    --exclude-pattern="/internal/" \
    --label="$label" \
    --delay=2 \
    --allow-sensitive \
    "https://pkg.go.dev/std?v=@go1.26.4"
  export_dataset "go-stdlib" "$label"
}

fetch_mdn_css() {
  label=css

  "$HISTER" index --recursive \
    --allowed-domain=developer.mozilla.org \
    --allowed-pattern="https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/.*" \
    --exclude-pattern="contributors.txt" \
    --label="$label" \
    https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/
  export_dataset "mdn-css" "$label"
}

fetch_mdn_html() {
  label=html

  "$HISTER" index --recursive \
    --allowed-domain=developer.mozilla.org \
    --allowed-pattern="https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/.*" \
    --exclude-pattern="contributors.txt" \
    --label="$label" \
    https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/
  export_dataset "mdn-html" "$label"
}

fetch_mdn_js() {
  label=javascript

  "$HISTER" index --recursive \
    --allowed-domain=developer.mozilla.org \
    --allowed-pattern="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/.*" \
    --exclude-pattern="contributors.txt" \
    --label="$label" \
    https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/
  export_dataset "mdn-js" "$label"
}

fetch_powershell() {
  label=powershell

  "$HISTER" index --recursive \
    --allowed-domain=learn.microsoft.com \
    --allowed-pattern="https://learn.microsoft.com/en-us/powershell/.*(powershell-7\.6|windowsserver2025-ps)$" \
    --label="$label" \
    --backend=chromedp \
    "https://learn.microsoft.com/en-us/powershell/scripting/how-to-use-docs?view=powershell-7.6" --force
  export_dataset "powershell" "$label"
}

fetch_dataset() {
  case "$1" in
    go-stdlib)
      fetch_go_stdlib
      ;;
    mdn-css)
      fetch_mdn_css
      ;;
    mdn-html)
      fetch_mdn_html
      ;;
    mdn-js)
      fetch_mdn_js
      ;;
    powershell)
      fetch_powershell
      ;;
    all)
      for dataset in $DATASETS; do
        fetch_dataset "$dataset"
      done
      ;;
    *)
      printf 'Unknown dataset: %s\n\n' "$1" >&2
      print_options >&2
      exit 1
      ;;
  esac
}

if [ "$#" -eq 0 ]; then
  print_options
  exit 0
fi

if [ "$#" -ne 1 ]; then
  printf 'Expected exactly one argument.\n\n' >&2
  print_options >&2
  exit 1
fi

fetch_dataset "$1"
