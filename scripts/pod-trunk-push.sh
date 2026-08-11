#!/bin/bash
# Publish one podspec to CocoaPods trunk, deciding success from the trunk API rather
# than from the exit code of `pod trunk push`.
#
# Why: trunk can report `Calling the GitHub commit API timed out` *after* it has
# already committed the spec. `pod trunk push` then exits 1, which aborts the rest of
# the semantic-release publish pipeline and silently skips the pods queued behind it.
# That is what happened in 0.12.6 (AmplitudeSessionReplay went out, the two wrapper
# pods did not) and, going by the versions missing from trunk, in 0.12.3 as well.
#
# Deliberately not `set -e`: a failing push has to be inspected, not fatal.
set -uo pipefail

podspec=${1:-}

if [ -z "$podspec" ] || [ ! -f "$podspec" ]; then
  echo "Usage: $0 <podspec>"
  exit 1
fi

attempts=${POD_PUSH_ATTEMPTS:-3}
retry_delay=${POD_PUSH_RETRY_DELAY:-30}

name=$(grep -E "^[[:space:]]*s\.name" "$podspec" | grep -oE '"[^"]+"' | tr -d '"')
version=$(grep -E "^amplitude_version" "$podspec" | grep -oE '"[^"]+"' | tr -d '"')

if [ -z "$name" ] || [ -z "$version" ]; then
  echo "✗ Could not read pod name / version from $podspec"
  exit 1
fi

# trunk is the source of truth for "does this version exist". Absent (or unreachable)
# is reported as not published, so a network blip never fakes a successful release.
is_published() {
  curl -sf --max-time 30 "https://trunk.cocoapods.org/api/v1/pods/${name}" \
    | grep -q "\"name\": *\"${version}\""
}

if is_published; then
  echo "✓ $name $version is already on trunk — nothing to push"
  exit 0
fi

# Arithmetic loop, not `seq 1 $attempts`: BSD seq counts *down* when the end is below
# the start, so a zero/garbled attempt count would silently retry instead of failing.
for (( attempt = 1; attempt <= attempts; attempt++ )); do
  echo "→ pod trunk push $podspec (attempt $attempt/$attempts)"
  if pod trunk push "$podspec" --allow-warnings --synchronous; then
    echo "✓ $name $version published"
    exit 0
  fi

  # The push may have landed despite the reported failure. Give trunk a moment to
  # finish the commit it was already making, then ask the API instead of guessing.
  echo "  push reported failure — re-checking trunk in ${retry_delay}s"
  sleep "$retry_delay"
  if is_published; then
    echo "✓ $name $version is on trunk despite the reported failure — treating as published"
    exit 0
  fi
done

echo "✗ Failed to publish $name $version after $attempts attempt(s)"
exit 1
