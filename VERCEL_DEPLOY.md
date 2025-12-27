# Service Desk Frontend - Vercel Deployment Guide

## Prerequisites
- GitHub account
- Vercel account (free)
- Backend API already deployed (Railway/Render/Fly.io)

## Step 1: Prepare for Deployment

The Flutter web app is already configured. Just ensure you have:
1. `.env.example` - Template for environment variables
2. `.gitignore` - Properly ignores sensitive files

## Step 2: Deploy to Vercel

### Option A: Deploy via Vercel Dashboard (Easiest)

1. Go to [vercel.com](https://vercel.com) and sign in with GitHub
2. Click **"Add New Project"**
3. Import your `service_desk_frontend` repository
4. Configure build settings:
   - **Framework Preset:** Other
   - **Build Command:** `flutter build web --release`
   - **Output Directory:** `build/web`
   - **Install Command:** (leave empty or add flutter setup)

### Option B: Use Pre-built Web Files

Since Vercel doesn't natively support Flutter, the easiest approach:

1. Build locally: `flutter build web --release`
2. The output is in `build/web/`
3. Deploy this folder directly to Vercel:
   ```
   cd build/web
   npx vercel deploy --prod
   ```

## Step 3: Configure Environment Variable

In Vercel Dashboard:
1. Go to your project → Settings → Environment Variables
2. Add: `API_BASE_URL` = `https://your-backend-url.railway.app`

## Step 4: Update API Service for Production

Before building for production, update `lib/services/api_service.dart`:

```dart
// Change from:
static const String baseUrl = 'http://127.0.0.1:8000/dashboard';

// To (for production):
static const String baseUrl = 'https://your-backend.railway.app/dashboard';
```

Or use environment-based configuration with `flutter_dotenv` package.

## Your Deployed URL

After deployment, Vercel will give you a URL like:
- `https://service-desk-frontend.vercel.app`

## Troubleshooting

- **CORS errors?** Ensure your backend allows requests from your Vercel domain
- **API not connecting?** Check the API_BASE_URL is correct
- **Build fails?** Ensure Flutter SDK is available or use pre-built approach
