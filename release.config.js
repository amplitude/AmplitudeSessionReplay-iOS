module.exports = {
  "branches": ["main"],
  "plugins": [
    ["@semantic-release/commit-analyzer", {
      "preset": "angular",
      "parserOpts": {
        "noteKeywords": ["BREAKING CHANGE", "BREAKING CHANGES", "BREAKING"]
      }
    }],
    ["@semantic-release/release-notes-generator", {
      "preset": "angular",
    }],
    ["@semantic-release/changelog", {
      "changelogFile": "CHANGELOG.md"
    }],
    "@semantic-release/github",
    [
      "@google/semantic-release-replace-plugin",
      {
        "replacements": [
          {
            "files": ["AmplitudeSessionReplay.podspec", "AmplitudeiOSSessionReplayMiddleware.podspec", "AmplitudeSwiftSessionReplayPlugin.podspec"],
            "from": "amplitude_version = \".*\"",
            "to": "amplitude_version = \"${nextRelease.version}\"",
            "results": [
              {
                "file": "AmplitudeSessionReplay.podspec",
                "hasChanged": true,
                "numMatches": 1,
                "numReplacements": 1
              },
              {
                "file": "AmplitudeiOSSessionReplayMiddleware.podspec",
                "hasChanged": true,
                "numMatches": 1,
                "numReplacements": 1
              },
              {
                "file": "AmplitudeSwiftSessionReplayPlugin.podspec",
                "hasChanged": true,
                "numMatches": 1,
                "numReplacements": 1
              },
            ],
            "countMatches": true
          },
        ]
      }
    ],
    ["@semantic-release/git", {
      "assets": ["AmplitudeSessionReplay.podspec", "AmplitudeiOSSessionReplayMiddleware.podspec", "AmplitudeSwiftSessionReplayPlugin.podspec", "CHANGELOG.md"],
      "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
    }],
    ["@semantic-release/exec", {
      "publishCmd": "./scripts/pod-trunk-push.sh AmplitudeSessionReplay.podspec",
    }],
    ["@semantic-release/exec", {
      "publishCmd": "pod repo update",
    }],
    ["@semantic-release/exec", {
      "publishCmd": "./scripts/pod-trunk-push.sh AmplitudeiOSSessionReplayMiddleware.podspec",
    }],
    ["@semantic-release/exec", {
      "publishCmd": "./scripts/pod-trunk-push.sh AmplitudeSwiftSessionReplayPlugin.podspec",
    }],
  ],
}
