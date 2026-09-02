#!/bin/bash
set -e

echo "Checking dependency version consistency across Package.swift and Podspec..."
echo ""

errors=0

# Function to extract version from Package.swift
# Format: .package(url: "https://github.com/amplitude/AmplitudeCore-Swift.git", from: "1.3.1")
extract_spm_version() {
  local package_name=$1
  local file=$2
  grep -E "github.com/amplitude/${package_name}" "$file" 2>/dev/null \
    | grep -oE "from:[[:space:]]*\"[0-9]+\.[0-9]+\.[0-9]+\"" \
    | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" || echo ""
}

# Function to extract version from Podspec
# Format: s.dependency 'AmplitudeCore', '>= 1.3.1', '< 2.0.0'
# Or: s.dependency 'AmplitudeCore', '~> 1.3.1'
extract_podspec_version() {
  local pod_name=$1
  local file=$2
  # Try >= format first
  version=$(grep -E "s\.dependency[[:space:]]+'${pod_name}'" "$file" 2>/dev/null \
    | grep -oE ">=[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+" \
    | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" || echo "")
  if [ -z "$version" ]; then
    # Try ~> format
    version=$(grep -E "s\.dependency[[:space:]]+'${pod_name}'" "$file" 2>/dev/null \
      | grep -oE "~>[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+" \
      | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" || echo "")
  fi
  echo "$version"
}

# Function to check a dependency across all manifests
check_dependency() {
  local spm_name=$1
  local pod_name=$2
  local podspec_file=$3
  local dep_errors=0

  echo "Checking: $pod_name"
  echo "----------------------------------------"

  spm_version=$(extract_spm_version "$spm_name" "Package.swift")
  pod_version=$(extract_podspec_version "$pod_name" "$podspec_file")

  echo "  Package.swift:  ${spm_version:-NOT FOUND}"
  echo "  ${podspec_file}: ${pod_version:-NOT FOUND}"

  if [ -z "$spm_version" ] || [ -z "$pod_version" ]; then
    echo "  ⚠ Warning: Could not find version in all files"
    dep_errors=1
  elif [ "$spm_version" != "$pod_version" ]; then
    echo "  ✗ Version mismatch! Package.swift has $spm_version but $podspec_file has $pod_version"
    dep_errors=1
  else
    echo "  ✓ All versions match: $spm_version"
  fi
  echo ""

  return $dep_errors
}

echo "================================================================"
echo "Dependency Version Report"
echo "================================================================"
echo ""

# Check AmplitudeCore-Swift / AmplitudeCore
if ! check_dependency "AmplitudeCore-Swift" "AmplitudeCore" "AmplitudeSessionReplay.podspec"; then
  errors=$((errors + 1))
fi

echo "================================================================"

if [ $errors -gt 0 ]; then
  echo "FAILED: Found $errors dependency version mismatch(es)"
  echo ""
  echo "Please ensure the minimum version requirements match across:"
  echo "  - Package.swift (from: \"x.y.z\")"
  echo "  - AmplitudeSessionReplay.podspec (>= x.y.z or ~> x.y.z)"
  exit 1
else
  echo "SUCCESS: All dependency versions are consistent"
fi
