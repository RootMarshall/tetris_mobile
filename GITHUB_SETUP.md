# GitHub Setup Instructions

## 1. Create the GitHub Repository

1. Go to https://github.com/new
2. Set **Repository name**: `tetris_mobile`
3. Set **Description**: "A lightweight, aesthetic Tetris mobile game built with Flutter for Android"
4. Choose **Public** (or Private if you prefer)
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click **Create repository**

## 2. Push Your Code to GitHub

After creating the repository on GitHub, run these commands in your terminal:

```bash
# Navigate to project directory
cd /Users/marshallmorgan/Projects/Tetris/tetris_mobile

# Initialize git (if not already done)
git init

# Add all files
git add -A

# Create initial commit
git commit -m "Initial commit: Complete Tetris mobile game with difficulty levels, animations, and high score tracking"

# Add GitHub as remote (replace YOUR_USERNAME with your actual GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/tetris_mobile.git

# Set main branch
git branch -M main

# Push to GitHub
git push -u origin main
```

## 3. Alternative: Using SSH

If you prefer SSH (after setting up SSH keys with GitHub):

```bash
git remote add origin git@github.com:YOUR_USERNAME/tetris_mobile.git
git branch -M main
git push -u origin main
```

## 4. Verify

After pushing, visit your repository at:
`https://github.com/YOUR_USERNAME/tetris_mobile`

The README.md will automatically display on the repository homepage.

## 5. Optional: Add Topics

On your GitHub repository page, you can add topics for better discoverability:
- `flutter`
- `dart`
- `tetris`
- `mobile-game`
- `android`
- `game-development`

## Future Updates

After making changes, push them with:

```bash
git add -A
git commit -m "Your commit message describing the changes"
git push
```

