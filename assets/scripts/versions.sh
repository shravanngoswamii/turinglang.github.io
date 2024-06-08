#!/bin/bash

# Define the repository URL
REPO_URL="https://api.github.com/repos/TuringLang/Turing.jl/tags"

# Fetch the tags from the repository
TAGS=$(curl -s $REPO_URL | grep 'name' | sed 's/.*: "\(.*\)",/\1/' | sort -r)

# Start building the new versions section
VERSIONS_SECTION=""
for TAG in $TAGS; do
  VERSIONS_SECTION=$(cat << EOF
$VERSIONS_SECTION
          - text: $TAG
            href: versions/$TAG/
EOF
  )
done

# Use awk to replace the existing versions section between the comments
awk -v versions="$VERSIONS_SECTION" '
  BEGIN { in_versions = 0 }
  /# The versions will be inserted here by the script/ {
    print $0
    print versions
    in_versions = 1
    next
  }
  /# The versions list ends here/ {
    in_versions = 0
  }
  !in_versions { print $0 }
' _quarto.yml > _quarto.yml.tmp && mv _quarto.yml.tmp _quarto.yml
