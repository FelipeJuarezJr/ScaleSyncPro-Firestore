"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { 
  signInWithEmailAndPassword, 
  signInWithPopup, 
  GoogleAuthProvider 
} from "firebase/auth";
import { auth } from "../firebase-client";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  // Force nocturnal theme for authentication page
  useEffect(() => {
    document.documentElement.setAttribute("data-theme", "nocturnal");
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg("");
    setSuccessMsg("");

    try {
      // Authenticate with Firebase
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      
      // Get Firebase ID Token
      const idToken = await user.getIdToken();
      
      // Set session cookie matching specifications
      document.cookie = `__session=${idToken}; path=/; max-age=3600; SameSite=Lax;`;

      // Save user session for perfect dashboard UI state compatibility
      const userData = {
        uid: user.uid,
        email: user.email,
        name: user.displayName || user.email?.split("@")[0] || "User",
        plan: "Pro", // Visual badge requirement
        loginTime: new Date().toISOString()
      };

      if (remember) {
        localStorage.setItem("userData", JSON.stringify(userData));
      } else {
        sessionStorage.setItem("userData", JSON.stringify(userData));
      }

      setSuccessMsg("Login successful! Redirecting...");
      setTimeout(() => {
        router.push("/");
      }, 1000);
    } catch (err: any) {
      console.error(err);
      setErrorMsg(err.message || "Invalid email or password");
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    setLoading(true);
    setErrorMsg("");
    setSuccessMsg("");

    try {
      const provider = new GoogleAuthProvider();
      const userCredential = await signInWithPopup(auth, provider);
      const user = userCredential.user;

      const idToken = await user.getIdToken();
      document.cookie = `__session=${idToken}; path=/; max-age=3600; SameSite=Lax;`;

      const userData = {
        uid: user.uid,
        email: user.email,
        name: user.displayName || user.email?.split("@")[0] || "User",
        plan: "Pro",
        loginTime: new Date().toISOString()
      };

      localStorage.setItem("userData", JSON.stringify(userData));

      setSuccessMsg("Google Sign-In successful! Redirecting...");
      setTimeout(() => {
        router.push("/");
      }, 1000);
    } catch (err: any) {
      console.error(err);
      setErrorMsg(err.message || "Failed to sign in with Google");
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <div className="auth-header">
          <div className="auth-brand">
            <i className="fas fa-dragon"></i>
            <span>ScaleSyncPro</span>
          </div>
          <h1>Welcome Back</h1>
          <p>Sign in to manage your reptile collection</p>
        </div>

        {errorMsg && (
          <div className="error-alert" style={{ color: "var(--danger-color)", marginBottom: "15px", textAlign: "center" }}>
            <i className="fas fa-exclamation-triangle"></i> {errorMsg}
          </div>
        )}

        {successMsg && (
          <div className="success-alert" style={{ color: "var(--success-color)", marginBottom: "15px", textAlign: "center" }}>
            <i className="fas fa-check-circle"></i> {successMsg}
          </div>
        )}

        <form onSubmit={handleLogin} className="auth-form">
          <div className="form-group">
            <label htmlFor="email">Email</label>
            <div className="input-group">
              <i className="fas fa-envelope"></i>
              <input 
                type="email" 
                id="email" 
                name="email" 
                placeholder="Enter your email" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required 
              />
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="password">Password</label>
            <div className="input-group">
              <i className="fas fa-lock"></i>
              <input 
                type={showPassword ? "text" : "password"} 
                id="password" 
                name="password" 
                placeholder="Enter your password" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required 
              />
              <button 
                type="button" 
                className="password-toggle" 
                onClick={() => setShowPassword(!showPassword)}
              >
                <i className={showPassword ? "fas fa-eye-slash" : "fas fa-eye"}></i>
              </button>
            </div>
          </div>

          <div className="form-options">
            <label className="checkbox-label">
              <input 
                type="checkbox" 
                name="remember"
                checked={remember}
                onChange={(e) => setRemember(e.target.checked)}
              />
              <span className="checkmark"></span>
              Remember me
            </label>
            <a href="#" className="forgot-password">Forgot password?</a>
          </div>

          <button type="submit" className="btn btn-primary auth-btn" disabled={loading}>
            {loading ? (
              <>
                <i className="fas fa-spinner fa-spin"></i>
                Signing In...
              </>
            ) : (
              <>
                <i className="fas fa-sign-in-alt"></i>
                Sign In
              </>
            )}
          </button>
        </form>

        <div className="auth-divider">
          <span>or</span>
        </div>

        <div className="social-auth">
          <button 
            type="button" 
            className="btn btn-social btn-google" 
            onClick={handleGoogleLogin}
            disabled={loading}
          >
            <i className="fab fa-google"></i>
            Continue with Google
          </button>
        </div>

        <div className="auth-footer">
          <p>Don't have an account? <Link href="/register">Sign up</Link></p>
        </div>
      </div>
    </div>
  );
}
