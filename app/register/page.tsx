"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { 
  createUserWithEmailAndPassword, 
  updateProfile,
  signInWithPopup, 
  GoogleAuthProvider 
} from "firebase/auth";
import { auth } from "../firebase-client";

export default function RegisterPage() {
  const router = useRouter();
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [collectionSize, setCollectionSize] = useState("");
  const [terms, setTerms] = useState(false);
  const [newsletter, setNewsletter] = useState(false);

  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");
  const [passwordStrength, setPasswordStrength] = useState({ strength: 0, feedback: "Password strength" });

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", "nocturnal");
  }, []);

  // Monitor password change to update strength indicator
  useEffect(() => {
    if (!password) {
      setPasswordStrength({ strength: 0, feedback: "Password strength" });
      return;
    }

    let strength = 0;
    // Length check
    if (password.length >= 8) strength += 25;
    if (password.length >= 12) strength += 25;
    // Character variety checks
    if (/[a-z]/.test(password)) strength += 15;
    if (/[A-Z]/.test(password)) strength += 15;
    if (/[0-9]/.test(password)) strength += 10;
    if (/[^A-Za-z0-9]/.test(password)) strength += 10;

    strength = Math.min(strength, 100);

    let feedback = "Weak";
    if (strength > 75) feedback = "Strong";
    else if (strength > 50) feedback = "Good";
    else if (strength > 25) feedback = "Fair";

    setPasswordStrength({ strength, feedback });
  }, [password]);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg("");
    setSuccessMsg("");

    if (password !== confirmPassword) {
      setErrorMsg("Passwords do not match");
      setLoading(false);
      return;
    }

    if (!terms) {
      setErrorMsg("You must accept the terms of service");
      setLoading(false);
      return;
    }

    try {
      // Create user
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Update user profile with full name
      const fullName = `${firstName} ${lastName}`;
      await updateProfile(user, { displayName: fullName });

      // Get ID Token
      const idToken = await user.getIdToken();
      document.cookie = `__session=${idToken}; path=/; max-age=3600; SameSite=Lax;`;

      // Save user session details
      const userData = {
        uid: user.uid,
        email: user.email,
        name: fullName,
        plan: "Free", // New account defaults to Free
        collectionSize,
        newsletter,
        loginTime: new Date().toISOString()
      };

      localStorage.setItem("userData", JSON.stringify(userData));

      setSuccessMsg("Account created successfully! Redirecting...");
      setTimeout(() => {
        router.push("/");
      }, 1000);
    } catch (err: any) {
      console.error(err);
      setErrorMsg(err.message || "Failed to create account");
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

  // Helper class for password strength bar
  const getStrengthBarClass = () => {
    const s = passwordStrength.strength;
    if (s <= 25) return "strength-fill weak";
    if (s <= 50) return "strength-fill fair";
    if (s <= 75) return "strength-fill good";
    return "strength-fill strong";
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <div className="auth-header">
          <div className="auth-brand">
            <i className="fas fa-dragon"></i>
            <span>RepFiles</span>
          </div>
          <h1>Create Account</h1>
          <p>Join RepFiles to start managing your reptile collection</p>
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

        <form onSubmit={handleRegister} className="auth-form">
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="firstName">First Name</label>
              <div className="input-group">
                <i className="fas fa-user"></i>
                <input 
                  type="text" 
                  id="firstName" 
                  name="firstName" 
                  placeholder="First name" 
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  required 
                />
              </div>
            </div>
            <div className="form-group">
              <label htmlFor="lastName">Last Name</label>
              <div className="input-group">
                <i className="fas fa-user"></i>
                <input 
                  type="text" 
                  id="lastName" 
                  name="lastName" 
                  placeholder="Last name" 
                  value={lastName}
                  onChange={(e) => setLastName(e.target.value)}
                  required 
                />
              </div>
            </div>
          </div>

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
                placeholder="Create a password" 
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
            {password && (
              <div className="password-strength" id="passwordStrength">
                <div className="strength-bar">
                  <div 
                    className={getStrengthBarClass()} 
                    style={{ width: `${passwordStrength.strength}%` }}
                  ></div>
                </div>
                <span className="strength-text" id="strengthText">{passwordStrength.feedback}</span>
              </div>
            )}
          </div>

          <div className="form-group">
            <label htmlFor="confirmPassword">Confirm Password</label>
            <div className="input-group">
              <i className="fas fa-lock"></i>
              <input 
                type={showConfirmPassword ? "text" : "password"} 
                id="confirmPassword" 
                name="confirmPassword" 
                placeholder="Confirm your password" 
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required 
              />
              <button 
                type="button" 
                className="password-toggle" 
                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
              >
                <i className={showConfirmPassword ? "fas fa-eye-slash" : "fas fa-eye"}></i>
              </button>
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="collectionSize">Collection Size</label>
            <div className="input-group">
              <i className="fas fa-dragon"></i>
              <select 
                id="collectionSize" 
                name="collectionSize" 
                value={collectionSize}
                onChange={(e) => setCollectionSize(e.target.value)}
                required
              >
                <option value="">Select collection size</option>
                <option value="1-5">1-5 reptiles</option>
                <option value="6-20">6-20 reptiles</option>
                <option value="21-50">21-50 reptiles</option>
                <option value="51-100">51-100 reptiles</option>
                <option value="100+">100+ reptiles</option>
              </select>
            </div>
          </div>

          <div className="form-options" style={{ flexDirection: "column", gap: "10px" }}>
            <label className="checkbox-label" style={{ display: "flex", alignItems: "center" }}>
              <input 
                type="checkbox" 
                name="terms" 
                checked={terms}
                onChange={(e) => setTerms(e.target.checked)}
                required 
              />
              <span className="checkmark"></span>
              <span>I agree to the <a href="#" className="terms-link">Terms of Service</a> and <a href="#" className="terms-link">Privacy Policy</a></span>
            </label>
            <label className="checkbox-label" style={{ display: "flex", alignItems: "center" }}>
              <input 
                type="checkbox" 
                name="newsletter"
                checked={newsletter}
                onChange={(e) => setNewsletter(e.target.checked)}
              />
              <span className="checkmark"></span>
              Subscribe to newsletter for updates and tips
            </label>
          </div>

          <button type="submit" className="btn btn-primary auth-btn" disabled={loading}>
            {loading ? (
              <>
                <i className="fas fa-spinner fa-spin"></i>
                Creating Account...
              </>
            ) : (
              <>
                <i className="fas fa-user-plus"></i>
                Create Account
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
          <p>Already have an account? <Link href="/login">Sign in</Link></p>
        </div>
      </div>
    </div>
  );
}
