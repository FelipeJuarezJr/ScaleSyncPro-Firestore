import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyDiT-1kdubTNYLe2waeCIYvGDx5nakKyh0",
  authDomain: "reptigramfirestore.firebaseapp.com",
  projectId: "reptigramfirestore",
  storageBucket: "reptigramfirestore.firebasestorage.app",
  messagingSenderId: "373955522567",
  appId: "1:373955522567:web:7163187c33d378455bbaa2",
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();
export const auth = getAuth(app);
