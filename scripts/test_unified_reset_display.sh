#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

ROW_FILE="$ROOT/codexBar/Views/AccountRowView.swift"

if [[ ! -f "$ROW_FILE" ]]; then
  echo "FAIL: AccountRowView.swift is missing"
  exit 1
fi

if ! rg -n 'primaryQuotaCard\(remainingPercent: account\.primaryRemainingPercent, resetStatusText: account\.primaryResetStatusText\)|primaryQuotaCard\(remainingPercent: 0, resetStatusText: account\.primaryResetStatusText\)' "$ROW_FILE" >/dev/null; then
  echo "FAIL: 5h reset hint is not shown in the unified quota block"
  exit 1
fi

if ! rg -n 'Text\(resetStatusText\)' "$ROW_FILE" >/dev/null; then
  echo "FAIL: 5h quota card does not render its reset status text"
  exit 1
fi

if ! rg -n 'weeklyQuotaCard' "$ROW_FILE" >/dev/null || ! rg -n 'Text\(account\.secondaryResetStatusText\)' "$ROW_FILE" >/dev/null; then
  echo "FAIL: 7d reset hint is not shown in the unified quota block"
  exit 1
fi

if rg -n 'Text\("5h: " \+ account\.primaryResetDescription\)|Text\("7d: " \+ account\.secondaryResetDescription\)' "$ROW_FILE" >/dev/null; then
  echo "FAIL: legacy split reset hints still exist outside the unified quota block"
  exit 1
fi

echo "PASS: unified reset display is present"
