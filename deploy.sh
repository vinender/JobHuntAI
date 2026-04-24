#!/bin/bash
set -e

# Configuration
GITHUB_USER="vinender"
REPO_NAME="JobHuntAI"
GITHUB_REPO="${GITHUB_USER}/${REPO_NAME}"

echo "=========================================================="
echo " Starting JobHuntAI Automated Deployment Pipeline"
echo " (GitHub + Vercel)"
echo "=========================================================="

# 1. Check dependencies
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Install instructions: https://github.com/cli/cli#installation"
    exit 1
fi

if ! command -v npx &> /dev/null; then
    echo "Error: Node/npm (npx) is not installed."
    exit 1
fi

# 2. Check GitHub Authentication
if ! gh auth status &> /dev/null; then
    echo "Error: You are not authenticated with GitHub CLI."
    echo "Please run 'gh auth login' or set GITHUB_TOKEN environment variable."
    exit 1
fi

# 3. Check and Create GitHub Repository
echo "-> Checking if repository ${GITHUB_REPO} exists on GitHub..."

# Suppress output to check existence quietly
if gh repo view "${GITHUB_REPO}" --json url &> /dev/null; then
    echo "-> Repository '${GITHUB_REPO}' already exists."
else
    echo "-> Repository '${GITHUB_REPO}' does not exist. Creating..."
    # Create the public repository and set origin remote
    gh repo create "${GITHUB_REPO}" --public --source=. --remote=origin --push
    echo "-> Repository successfully created on GitHub."
fi

# 4. Synchronize Remote and Push
# Ensure git holds the correct origin URL
if ! git remote get-url origin &> /dev/null; then
    git remote add origin "https://github.com/${GITHUB_REPO}.git"
fi

echo "-> Committing and pushing latest code to GitHub..."
git config --global init.defaultBranch main
git branch -M main
git add .
# Commit only if there are changes
git diff-index --quiet HEAD || git commit -m "Auto-deploy commit: $(date +'%Y-%m-%d %H:%M:%S')"
git push -u origin main

# 5. Deploy to Vercel
echo "-> Building and Deploying to Vercel (Production Headless)..."
# Using npx vercel --yes to completely bypass interactive prompts
# We explicitly set project name in project.json or depend on folder name internally, Vercel infers.
# Assuming you have run `npx vercel login` previously or VERCEL_TOKEN is set.
npx -y vercel --prod --yes

echo "=========================================================="
echo " Deployment Pipeline Completed Successfully!"
echo "=========================================================="
