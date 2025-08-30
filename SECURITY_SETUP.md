# 🔐 Security Setup Guide

## ⚠️ IMPORTANT: Before Pushing to GitHub

This project contains sensitive API keys and configuration files that must NOT be exposed publicly. Follow this guide to secure your project.

## 🚨 Files That Contain Secrets

### Already Protected (in .gitignore):
- `a.env` - Contains your OpenRouter API key and Firebase keys
- `android/app/google-services.json` - Contains Firebase Android configuration
- `ios/Runner/GoogleService-Info.plist` - Contains Firebase iOS configuration  
- `lib/firebase_options.dart` - Contains Firebase configuration

### Template Files (Safe to commit):
- `a.env.template` - Template for environment variables
- `android/app/google-services.json.template` - Template for Android Firebase config
- `lib/firebase_options.dart.template` - Template for Firebase options

## 🔧 Setup Instructions for New Developers

### 1. Environment Variables Setup
Copy the template and add your real values:
```bash
cp a.env.template a.env
```

Edit `a.env` with your actual API keys:
```env
# Firebase Configuration
WEB_API_KEY=your_web_api_key_here
WEB_APP_ID=your_web_app_id_here
# ... other Firebase keys

# OpenRouter API Configuration  
LLAMA_API_KEY=your_openrouter_api_key_here
LLAMA_API_URL=https://openrouter.ai/api/v1/chat/completions
```

### 2. Firebase Configuration
1. Copy the template: `cp android/app/google-services.json.template android/app/google-services.json`
2. Replace with your actual Firebase configuration from Firebase Console
3. Do the same for iOS if needed

### 3. Generate Firebase Options
Run the FlutterFire CLI to generate the proper `firebase_options.dart`:
```bash
flutterfire configure
```

## 🛡️ Security Checklist Before Committing

- [ ] `a.env` is in .gitignore and contains no real keys in repo
- [ ] `android/app/google-services.json` is in .gitignore  
- [ ] `lib/firebase_options.dart` is in .gitignore
- [ ] Only template files are committed
- [ ] No hardcoded API keys in source code
- [ ] All secrets loaded from environment variables

## 🔍 How to Check for Leaks

Before pushing, run:
```bash
git status
git diff --cached
```

Make sure no files with real API keys are staged for commit.

## 📝 API Keys Used in This Project

1. **OpenRouter API Key** - For AI chat functionality
2. **Firebase API Keys** - For authentication and database
3. **Firebase Project Configuration** - Project IDs, app IDs, etc.

## 🚨 If You Accidentally Commit Secrets

1. **Immediately revoke/regenerate** all exposed API keys
2. **Remove from git history** using git filter-branch or BFG Repo-Cleaner
3. **Update .gitignore** to prevent future leaks
4. **Force push** the cleaned history

## 📞 Need Help?

If you're unsure about any security aspect, ask before pushing to GitHub!
