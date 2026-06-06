# Backend Architecture Specification & Replication Guide

This document provides a comprehensive technical specification of the backend systems discovered across the workspace environments. The setup consists of a **Serverless/Next.js and Cloud Functions Admin Backend** (supporting ReptiGram) and a **Headless RPA Scraper/Adapter Bridge** (APEX-Hub).

---

## 1. System Overview & Architecture Patterns

The backend infrastructure is split into two primary backend services supporting the mobile and web clients:

```mermaid
graph TD
    Client[Frontend UI / Mobile Client] -->|Direct Reads/Writes via SDK| Firestore[(Cloud Firestore)]
    Client -->|Server Actions| NextServer[Next.js Server Actions]
    NextServer -->|Firebase Admin SDK| Firestore
    NextServer -->|Firebase Admin SDK| Auth[Firebase Auth]
    
    subgraph Core App Features (All Internal)
        Firestore -.-> Track[Breeding Tracker Ledger]
        Firestore -.-> Social[Social Media Feed & Messaging]
        Firestore -.-> Market[Internal Marketplace Listings]
    end
    ```

### A. Next.js Server Actions & Admin Backend (`ReptiGramFirestore`)
- **Pattern**: Next.js 14 App Router Server Actions + Firebase Admin SDK.
- **Role**: Secure administrative capabilities (soft deletes, account suspension, cascade deletions, logs auditing).
- **Database Layer**: Direct Firestore operations, with schema enforcement and access controls implemented via security rules.

### B. Headless RPA Bridge Server (`APEX-Hub`)
- **Pattern**: Controller-Adapter Pattern (Express.js application).
- **Role**: Headless browser automation bridge running Puppeteer to scrape listings and perform synchronization operations (such as marking items as sold) on third-party marketplace forums.
- **Browser Lifecycle**: Managed via a persistent global browser instance with automated self-healing for stale locks.

---

## 2. TypeScript Configurations

TypeScript is configured with strict compiler settings, project references, and module mapping.

### A. Next.js Admin Panel Configuration (`tsconfig.json`)
```json
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### B. APEX-Hub Bridge Project References (`tsconfig.json`)
The RPA backend separates node configuration from client app code via references:
```json
{
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ]
}
```
* **`tsconfig.app.json`** compiles application code (target `ES2020`, module resolution `Bundler`, strict checking, prevents unused variables and unchecked imports).
* **`tsconfig.node.json`** compiles build-time Vite configurations (target `ES2022`).

---

## 3. Database Layer Validation & Firestore Rules

No Mongoose database layers are utilized; instead, database validation is enforced using **Cloud Firestore Security Rules** (`firestore_rules.rules`) and transactional server scripts.

### Key Validation Patterns In Rules:
1. **Field Existence Check**:
   ```javascript
   allow create, update: if request.auth != null && 
     request.resource.data.keys().hasAny(['uid']);
   ```
2. **Resource Mutation Validation (Delta Analysis)**:
   Non-owners are prohibited from editing post/photo documents except for specific like metrics:
   ```javascript
   allow update: if request.auth != null
     && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['likesCount', 'recentLikers', 'likesMap']);
   ```
3. **Regex-Based String Match Checks**:
   Validating chat and message thread membership using string matching rules:
   ```javascript
   allow read, write: if request.auth != null 
     && (chatId.matches(request.auth.uid + '_.*') || chatId.matches('.*_' + request.auth.uid));
   ```
4. **Custom Claims Verification (RBAC)**:
   ```javascript
   allow read, write: if request.auth != null && request.auth.token.admin == true;
   ```

---

## 4. Authentication Middleware & Custom Claims

### A. Next.js Verification Middleware (`actions.ts`)
The server actions decode cookies containing the Firebase ID Token.
* **Token/Session verification flow**:
  ```typescript
  export async function verifyAdminClaim(sessionToken: string): Promise<boolean> {
    if (!sessionToken) return false;

    // Local development bypass to streamline test suites
    if (process.env.NODE_ENV === "development" && sessionToken === "dev-admin-bypass") {
      console.log("Local development admin bypass token successfully authorized.");
      return true;
    }

    const { auth } = getAdminAuth();
    
    try {
      const decodedToken = await auth.verifyIdToken(sessionToken);
      return decodedToken.admin === true;
    } catch (error) {
      try {
        const decodedCookie = await auth.verifySessionCookie(sessionToken);
        return decodedCookie.admin === true;
      } catch (cookieError) {
        console.error("Error verifying token or cookie admin claim:", error, cookieError);
        return false;
      }
    }
  }
  ```

### B. Client-Side Dev claim Initialization (`DevAdminInitializer.tsx`)
In development contexts, developers can claim administrative status by writing a token directly into the browser's `__session` cookie:
```typescript
document.cookie = `__session=dev-admin-bypass; path=/; max-age=3600; SameSite=Lax;`;
```
This unblocks testing of admin panels without setting up external Firebase Auth mock parameters.

---

## 5. Error Handling & Self-Healing Mechanics

### A. Headless Browser Lock Self-Healing (RPA Server)
Puppeteer launches can raise `SingletonLock` errors if Chrome crashed previously and lock files were not cleared. The server catches this error and triggers `clearLocks()` before retry:
```javascript
const clearLocks = () => {
  const lockFiles = ['SingletonLock', 'SingletonCookie', 'SingletonSocket'];
  lockFiles.forEach(file => {
    const fullPath = path.join(userDataDir, file);
    try {
      const stats = fs.lstatSync(fullPath);
      if (file === 'SingletonLock' && stats.isSymbolicLink()) {
        const target = fs.readlinkSync(fullPath);
        const pidMatch = target.match(/-(\d+)$/);
        if (pidMatch) {
          const pid = parseInt(pidMatch[1]);
          try { process.kill(pid, 9); } catch (killErr) { /* dead */ }
        }
      }
      fs.unlinkSync(fullPath);
    } catch (fsErr) { /* ENOENT ignored */ }
  });
};
```

### B. Server Actions Error Standard
Next.js server actions wrap business logic in `try/catch` and return an structured object rather than allowing exceptions to bubble uncaught:
```typescript
try {
  // Logic
  return { success: true };
} catch (error: any) {
  console.error("Action error:", error);
  return { success: false, error: error.message };
}
```

### C. Cloud Functions Error Handling
Firestore-triggered background tasks handle missing target documents (e.g., deleted tokens, missing users) gracefully by executing log warnings and returning `null` rather than failing the execution queue.

---

## 6. Package Dependencies (`package.json`)

To replicate these setups, your target `package.json` configurations should include these dependencies:

### A. RPA Scraper Bridge Server (`APEX-Hub/package.json`)
```json
{
  "dependencies": {
    "express": "^5.2.1",
    "cors": "^2.8.6",
    "puppeteer": "^24.41.0",
    "puppeteer-extra": "^3.3.6",
    "puppeteer-extra-plugin-stealth": "^2.11.2",
    "firebase": "^12.12.1"
  },
  "devDependencies": {
    "typescript": "~5.6.2",
    "concurrently": "^9.2.1"
  }
}
```

### B. Next.js Server & Admin Dashboard (`ReptiGramFirestore/package.json`)
```json
{
  "dependencies": {
    "next": "^14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "firebase": "^10.8.0",
    "firebase-admin": "^12.0.0"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@types/node": "^20.11.16"
  }
}
```

### C. Cloud Functions (`ReptiGramFirestore/functions/package.json`)
```json
{
  "dependencies": {
    "firebase-admin": "^11.8.0",
    "firebase-functions": "^4.3.1"
  },
  "engines": {
    "node": "18"
  }
}
```

---

## 7. Step-by-Step Replication Guide

To spin up this backend ecosystem from scratch in a new project:

### Step 1: Firebase Project Setup
1. Create a Firebase Project via the Console.
2. Enable **Firestore Database** in Native Mode.
3. Enable **Firebase Authentication** (Email/Password).
4. Download the Service Account private key JSON. Rename it to `service-account-key.json` and place it in the root directory.

### Step 2: Next.js Admin Panel Setup
1. Create a Next.js application using TypeScript.
2. Copy the `actions.ts` into a server-bound library directory. Ensure `"use server"` is present.
3. Ensure token cookies are read from header cookie states:
   ```typescript
   const cookieStore = cookies();
   const sessionToken = cookieStore.get("__session")?.value || "";
   ```
4. Define the Firestore security rules matching `firestore_rules.rules` to enforce document protections.

### Step 3: Cloud Functions Setup
1. Run `firebase init functions` and select Javascript or TypeScript (Node 18+).
2. Deploy triggers listening to Firestore write operations:
   * `chats/{chatId}/messages/{messageId}` -> `onCreate` (sends FCM message to recipient).
   * `conversations/{conversationId}/messages/{messageId}` -> `onCreate` (sends FCM message).

### Step 4: RPA Scraper Bridge Setup
1. Create an Express.js app. Configure the controller-adapter pattern.
2. Initialize Puppeteer with the stealth plugin. Ensure args include `--no-sandbox` for hosting compliance.
3. Include the lock cleanup hook inside your browser initialization chain to resolve Singleton lockouts automatically on startup.
