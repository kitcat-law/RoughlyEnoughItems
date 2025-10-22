#!/usr/bin/env bash
set -euo pipefail

echo "▶ preparing compiler opts…"

INIT_DIR=".gradle-init"
INIT_FILE="${INIT_DIR}/javac-opts.init.gradle"
mkdir -p "${INIT_DIR}"
cat > "${INIT_FILE}" <<'INITEOF'
allprojects {
  tasks.withType(JavaCompile).configureEach {
    options.compilerArgs += ['-Xmaxerrs','5000','-Xmaxwarns','5000','-Xdiags:verbose']
  }
}
INITEOF

mkdir -p build/logs
FULL_LOG="build/logs/javac_full.log"
ERRORS_LOG="build/logs/javac_errors_only.log"

# --- Git pull (quiet to terminal; output goes to full log) ---
echo "▶ updating repo (git pull --rebase)…"
set +e
git pull --rebase >> "${FULL_LOG}" 2>&1
GIT_EXIT=$?
set -e
if [ "${GIT_EXIT}" -ne 0 ]; then
  echo "⚠️  git pull failed (see full log); continuing with local state…"
fi

echo "▶ building (quiet)…"
set +e
./gradlew clean :fabric:build :fabric:remapJar --console=plain --no-daemon \
  --init-script "${INIT_FILE}" \
  > "${FULL_LOG}" 2>&1
GRADLE_EXIT=$?
set -e

echo "▶ extracting full error blocks…"
awk '
function flush() { if (capturing) { print buffer; print ""; buffer=""; } }
BEGIN { capturing=0; buffer=""; }
{
  if ($0 ~ /\.java:[0-9]+: (error|warning): /) {
    if (capturing) flush();
    if ($0 ~ /\.java:[0-9]+: error: /) {
      capturing=1; buffer=$0 ORS;
    } else {
      capturing=0; buffer="";
    }
    next;
  }
  if (capturing) buffer = buffer $0 ORS;
}
END { flush(); }
' "${FULL_LOG}" > "${ERRORS_LOG}"

# Count errors (headers) in the errors-only log
ERROR_COUNT=$(grep -E '\.java:[0-9]+: error: ' -c "${ERRORS_LOG}" || true)

if [ "${GRADLE_EXIT}" -eq 0 ]; then
  echo "✅ BUILD SUCCEEDED — ${ERROR_COUNT} errors"
else
  echo "❌ BUILD FAILED — ${ERROR_COUNT} errors (exit code ${GRADLE_EXIT})"
fi

echo "ℹ️  Logs saved (overwritten each run):"
echo "   Full:   $(pwd)/${FULL_LOG}"
echo "   Errors: $(pwd)/${ERRORS_LOG}"
