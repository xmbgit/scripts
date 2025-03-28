#!/bin/bash

# exports the current branch (if any) otherwise null
echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'not a repo')"
