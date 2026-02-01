#!/bin/bash

echo "🚀 UAIXQ Auto Git Push"
echo ""

# Git config
git config --global user.email "your@email.com"
git config --global user.name "1xOnex-aXbot"

# Add all
echo "📦 Adding files..."
git add .

# Commit with timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
git commit -m "Auto update: $TIMESTAMP"

# Push
echo "⬆️  Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Pushed to GitHub!"
echo "🌐 View at: https://github.com/1xOnex-aXbot/aXQversum"

