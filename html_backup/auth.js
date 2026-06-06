// Authentication functionality for RepFiles

document.addEventListener('DOMContentLoaded', function() {
    // Force nocturnal theme for auth pages
    document.documentElement.setAttribute('data-theme', 'nocturnal');
    
    // Password toggle functionality
    window.togglePassword = function(inputId) {
        const input = document.getElementById(inputId);
        const toggle = input.parentElement.querySelector('.password-toggle i');
        
        if (input.type === 'password') {
            input.type = 'text';
            toggle.className = 'fas fa-eye-slash';
        } else {
            input.type = 'password';
            toggle.className = 'fas fa-eye';
        }
    };
    
    // Password strength checker (for register page)
    const passwordInput = document.getElementById('password');
    if (passwordInput) {
        passwordInput.addEventListener('input', function() {
            checkPasswordStrength(this.value);
        });
    }
    
    function checkPasswordStrength(password) {
        const strengthFill = document.getElementById('strengthFill');
        const strengthText = document.getElementById('strengthText');
        
        if (!strengthFill || !strengthText) return;
        
        let strength = 0;
        let feedback = '';
        
        // Length check
        if (password.length >= 8) strength += 25;
        if (password.length >= 12) strength += 25;
        
        // Character variety checks
        if (/[a-z]/.test(password)) strength += 25;
        if (/[A-Z]/.test(password)) strength += 25;
        if (/[0-9]/.test(password)) strength += 25;
        if (/[^A-Za-z0-9]/.test(password)) strength += 25;
        
        // Cap at 100%
        strength = Math.min(strength, 100);
        
        // Update UI
        strengthFill.className = 'strength-fill';
        if (strength <= 25) {
            strengthFill.classList.add('weak');
            feedback = 'Weak';
        } else if (strength <= 50) {
            strengthFill.classList.add('fair');
            feedback = 'Fair';
        } else if (strength <= 75) {
            strengthFill.classList.add('good');
            feedback = 'Good';
        } else {
            strengthFill.classList.add('strong');
            feedback = 'Strong';
        }
        
        strengthText.textContent = feedback;
    }
    
    // Form validation and submission
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');
    
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }
    
    if (registerForm) {
        registerForm.addEventListener('submit', handleRegister);
    }
    
    function handleLogin(e) {
        e.preventDefault();
        
        const formData = new FormData(loginForm);
        const email = formData.get('email');
        const password = formData.get('password');
        const remember = formData.get('remember');
        
        // Basic validation
        if (!email || !password) {
            showNotification('Please fill in all required fields', 'error');
            return;
        }
        
        if (!isValidEmail(email)) {
            showNotification('Please enter a valid email address', 'error');
            return;
        }
        
        // Show loading state
        const submitBtn = loginForm.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing In...';
        submitBtn.disabled = true;
        
        // Simulate login process (replace with actual authentication)
        setTimeout(() => {
            // For demo purposes, accept any email/password combination
            if (email && password) {
                // Store user session
                const userData = {
                    email: email,
                    name: email.split('@')[0],
                    plan: 'Pro',
                    loginTime: new Date().toISOString()
                };
                
                if (remember) {
                    localStorage.setItem('userData', JSON.stringify(userData));
                } else {
                    sessionStorage.setItem('userData', JSON.stringify(userData));
                }
                
                showNotification('Login successful! Redirecting...', 'success');
                
                // Redirect to main app
                setTimeout(() => {
                    window.location.href = 'index.html';
                }, 1000);
            } else {
                showNotification('Invalid email or password', 'error');
                submitBtn.innerHTML = originalText;
                submitBtn.disabled = false;
            }
        }, 1500);
    }
    
    function handleRegister(e) {
        e.preventDefault();
        
        const formData = new FormData(registerForm);
        const firstName = formData.get('firstName');
        const lastName = formData.get('lastName');
        const email = formData.get('email');
        const password = formData.get('password');
        const confirmPassword = formData.get('confirmPassword');
        const collectionSize = formData.get('collectionSize');
        const terms = formData.get('terms');
        const newsletter = formData.get('newsletter');
        
        // Validation
        if (!firstName || !lastName || !email || !password || !confirmPassword || !collectionSize) {
            showNotification('Please fill in all required fields', 'error');
            return;
        }
        
        if (!isValidEmail(email)) {
            showNotification('Please enter a valid email address', 'error');
            return;
        }
        
        if (password !== confirmPassword) {
            showNotification('Passwords do not match', 'error');
            return;
        }
        
        if (password.length < 8) {
            showNotification('Password must be at least 8 characters long', 'error');
            return;
        }
        
        if (!terms) {
            showNotification('Please accept the Terms of Service', 'error');
            return;
        }
        
        // Show loading state
        const submitBtn = registerForm.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating Account...';
        submitBtn.disabled = true;
        
        // Simulate registration process (replace with actual registration)
        setTimeout(() => {
            // Store user data
            const userData = {
                firstName: firstName,
                lastName: lastName,
                email: email,
                collectionSize: collectionSize,
                newsletter: newsletter === 'on',
                plan: 'Free',
                registrationTime: new Date().toISOString()
            };
            
            localStorage.setItem('userData', JSON.stringify(userData));
            
            showNotification('Account created successfully! Redirecting...', 'success');
            
            // Redirect to main app
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 1000);
        }, 2000);
    }
    
    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    function showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
                <span>${message}</span>
            </div>
            <button class="notification-close">
                <i class="fas fa-times"></i>
            </button>
        `;
        
        // Add styles
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            padding: 15px 20px;
            box-shadow: var(--shadow-lg);
            z-index: 10000;
            display: flex;
            align-items: center;
            gap: 15px;
            min-width: 300px;
            max-width: 400px;
            animation: slideInRight 0.3s ease;
        `;
        
        // Add notification styles to head if not already present
        if (!document.getElementById('notification-styles')) {
            const style = document.createElement('style');
            style.id = 'notification-styles';
            style.textContent = `
                @keyframes slideInRight {
                    from { transform: translateX(100%); opacity: 0; }
                    to { transform: translateX(0); opacity: 1; }
                }
                @keyframes slideOutRight {
                    from { transform: translateX(0); opacity: 1; }
                    to { transform: translateX(100%); opacity: 0; }
                }
                .notification-content {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    flex: 1;
                }
                .notification-content i {
                    color: var(--${type === 'success' ? 'success' : type === 'error' ? 'danger' : 'info'}-color);
                }
                .notification-close {
                    background: none;
                    border: none;
                    color: var(--text-light);
                    cursor: pointer;
                    padding: 4px;
                    border-radius: var(--border-radius-sm);
                    transition: var(--transition);
                }
                .notification-close:hover {
                    color: var(--text-primary);
                    background: var(--bg-secondary);
                }
                .notification-success .notification-content i { color: var(--success-color); }
                .notification-error .notification-content i { color: var(--danger-color); }
                .notification-info .notification-content i { color: var(--info-color); }
            `;
            document.head.appendChild(style);
        }
        
        // Add to page
        document.body.appendChild(notification);
        
        // Close button functionality
        const closeBtn = notification.querySelector('.notification-close');
        closeBtn.addEventListener('click', () => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        });
        
        // Auto remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.style.animation = 'slideOutRight 0.3s ease';
                setTimeout(() => {
                    if (notification.parentNode) {
                        notification.parentNode.removeChild(notification);
                    }
                }, 300);
            }
        }, 5000);
    }
    
    // Social auth buttons (placeholder functionality)
    const socialButtons = document.querySelectorAll('.btn-social');
    socialButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const provider = this.classList.contains('btn-google') ? 'Google' : 'GitHub';
            showNotification(`${provider} authentication coming soon!`, 'info');
        });
    });
}); 