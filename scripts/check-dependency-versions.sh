#!/bin/bash
set -e

extract_spm_version() {
  local package_name=$1
  local file=$2
  grep -E "github.com/amplitude/${package_name}" "$file" 2>/dev/null \
    | grep -oE "from:[[:space:]]*\"[0-9]+\.[0-9]+\.[0-9]+\"" \
    | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" || echo ""
}

expected=$(extract_spm_version "AmplitudeCore-Swift" Package.swift)
if [ -z "$expected" ]; then
  echo "Missing AmplitudeCore-Swift minimum version in Package.swift" >&2
  exit 1
fi

for manifest in Package@swift-*.swift; do
  [ -f "$manifest" ] || continue
  actual=$(extract_spm_version "AmplitudeCore-Swift" "$manifest")
  if [ "$actual" != "$expected" ]; then
    echo "$manifest requires AmplitudeCore-Swift ${actual:-<missing>}, expected $expected" >&2
    exit 1
  fi
done

echo "All Swift package manifests require AmplitudeCore-Swift $expected"
