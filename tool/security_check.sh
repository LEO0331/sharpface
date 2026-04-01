#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Checking accidental secrets..."
if rg -n --hidden --glob '!.git' --glob '!build' --glob '!coverage' \
  '(sk-[A-Za-z0-9]{20,}|OPENAI_API_KEY\s*=\s*["'\''][^"'\'']+["'\''])' .; then
  echo "Potential secret exposure found. Please review above lines."
  exit 1
else
  echo "OK: no obvious API key patterns found."
fi

echo "[2/4] Checking Firebase rules risky patterns..."
if rg -n 'allow write:\s*if true|allow read, write:\s*if true' firestore.rules; then
  echo "Risky firestore rules found."
  exit 1
else
  echo "OK: no direct public write rule found."
fi

echo "[3/4] Checking gitignored runtime secrets..."
if ! rg -n '^\.env$|^\*\.env$|^firebase_options\.dart$' .gitignore >/dev/null 2>&1; then
  echo "Warning: consider adding .env / generated secret files into .gitignore"
else
  echo "OK: .gitignore contains secret-related entries."
fi

echo "[4/4] Flutter static checks..."
if [[ "${SKIP_FLUTTER_ANALYZE:-0}" == "1" ]]; then
  echo "SKIPPED: flutter analyze (SKIP_FLUTTER_ANALYZE=1)."
else
  flutter analyze >/dev/null
  echo "OK: flutter analyze passed."
fi

echo "Security baseline check completed."
