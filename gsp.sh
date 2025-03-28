#!/bin/bash

# How to Sign A Commit for Vigilant Verification
git fetch origin main;
git rebase origin/main;
sleep 1;
git add  -A;
git commit -S;
git push;
