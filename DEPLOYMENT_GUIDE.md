# SkillCommerce (Dokkho Lok Khuji) — Free Production Deployment Guide

**Target Architecture:**
- **Frontend Customer Portal:** React 18 + Vite + Remotion → **Vercel** / **Netlify** / **Cloudflare Pages** (Free Tier)
- **Backend Web API:** ASP.NET Core .NET 9 + SignalR → **Render** / **Railway** / **Fly.io** (Free/Hobby Tier)
- **Relational Database:** Microsoft SQL Server / Azure SQL / Neon Postgres / Supabase → **Free Cloud Database Tier**
- **Mobile Client:** Flutter Web Static Distribution & Native SDK Archive (`/downloads/`)

---

## 1. Relational Database Deployment

### Option A: Azure SQL Database (Free Tier)
1. In the [Azure Portal](https://portal.azure.com), create a free Azure SQL database (32,000 vCore-seconds free per month).
2. Note your connection string:
   ```env
   Server=tcp:<your-server>.database.windows.net,1433;Initial Catalog=SkillCommerceDb;Persist Security Info=False;User ID=<user>;Password=<password>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
   ```
3. Run the EF Core migrations from your deployment machine:
   ```bash
   cd Skill-Based_E-Commerce_Platform-Project/Backend
   dotnet ef database update --project src/SkillCommerce.Infrastructure --startup-project src/SkillCommerce.Api
   ```

### Option B: Docker Compose on any VPS / Free Cloud VM
1. Execute the production database stack:
   ```bash
   cd Skill-Based_E-Commerce_Platform-Project/Database
   docker compose up -d
   ```
2. The bundled migration scripts (`relational/seeds/010_seed_all_35_skill_categories.sql` and `011_seed_dhaka_public_service_listings.sql`) will initialize automatically.

---

## 2. ASP.NET Core .NET 9 Web API Deployment (Render / Railway)

### Deploying on Render (Free Web Service)
1. Link your GitHub repository to [Render.com](https://render.com).
2. Choose **Web Service** and select **Docker** (or .NET Environment).
3. Set the Root Directory to `Skill-Based_E-Commerce_Platform-Project/Backend`.
4. Configure the required Environment Variables:
   | Variable | Value / Description |
   | :--- | :--- |
   | `ASPNETCORE_ENVIRONMENT` | `Production` |
   | `ConnectionStrings__DefaultConnection` | `Server=tcp:...;Database=SkillCommerceDb;...` |
   | `Jwt__SigningKey` | High-entropy 64-byte secret string |
   | `Jwt__Issuer` | `https://api.yourdomain.com` |
   | `Jwt__Audience` | `https://yourdomain.com` |
   | `Cors__AllowedOrigins__0` | `https://your-frontend.vercel.app` |
   | `Cors__AllowedOrigins__1` | `https://yourdomain.com` |
5. Verification Health Check Endpoints:
   - Live check: `GET https://your-api.onrender.com/health/live`
   - Readiness check (SQL DB verify): `GET https://your-api.onrender.com/health/ready`

---

## 3. React Customer Marketplace Portal Deployment (Vercel / Netlify)

### Deploying on Vercel
1. In [Vercel](https://vercel.com), click **Add New Project** and import the repository.
2. Configure Project Settings:
   - **Framework Preset**: `Vite`
   - **Root Directory**: `Skill-Based_E-Commerce_Platform-Project/Frontend/react-customer-portal`
   - **Build Command**: `vite build`
   - **Output Directory**: `dist`
3. Set Environment Variables:
   ```env
   VITE_APP_MODE=live
   VITE_API_BASE_URL=https://your-api.onrender.com
   VITE_PROVIDER_ORIGIN=https://your-provider-portal.vercel.app
   ```
4. For Single Page Application (SPA) routing, add `vercel.json` if needed:
   ```json
   {
     "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
   }
   ```

---

## 4. Mobile App Distribution & Installation

The customer portal automatically hosts two mobile installation methods right in `<ScenicNavbar />`:
1. **Interactive PWA Mobile App** (`/downloads/mobile_app.html`):
   - Visitors scanning the QR code with their smartphone camera can tap **"Add to Home Screen"** on both **Android (Chrome)** and **iOS (Safari)** for an app-store-free instant installation.
2. **Ready-Made Native Mobile SDK (.ZIP)**:
   - Developers and mobile users can download the complete standalone Flutter mobile client bundle from `/downloads/SkillCommerce_Mobile_SDK_v1.0.0.zip` (60 MB).
   - Contains clean state management (`flutter_bloc`), OpenStreetMap telemetry, SignalR real-time dispatch, and bilingual localization (`bn-BD` / `en-US`).

