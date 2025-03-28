#!/bin/bash

# fix out of sync trees (just stop writing in web browser silly goose)
git fetch origin main;
git rebase origin/main;
sleep 3; 
git push origin main;

