// Basic functionality for RepFiles prototype

// Authentication state management
function checkAuthState() {
    const userData = JSON.parse(localStorage.getItem('userData') || sessionStorage.getItem('userData') || 'null');
    
    if (!userData) {
        // Redirect to login if not authenticated
        if (!window.location.href.includes('login.html') && !window.location.href.includes('register.html')) {
            window.location.href = 'login.html';
            return;
        }
    } else {
        // Update UI with user data
        updateUserInterface(userData);
    }
}

function updateUserInterface(userData) {
    const userName = document.getElementById('userName');
    const userPlan = document.getElementById('userPlan');
    const dropdownUserName = document.getElementById('dropdownUserName');
    const dropdownUserEmail = document.getElementById('dropdownUserEmail');
    
    if (userName) userName.textContent = userData.name || userData.firstName || 'User';
    if (userPlan) userPlan.textContent = userData.plan || 'Free';
    if (dropdownUserName) dropdownUserName.textContent = userData.name || `${userData.firstName} ${userData.lastName}` || 'User';
    if (dropdownUserEmail) dropdownUserEmail.textContent = userData.email || '';
}

function logout() {
    localStorage.removeItem('userData');
    sessionStorage.removeItem('userData');
    window.location.href = 'login.html';
}

// Navigation
document.addEventListener('DOMContentLoaded', function() {
    // Check authentication state
    checkAuthState();
    
    // User dropdown functionality
    const userMenuToggle = document.getElementById('userMenuToggle');
    const userDropdown = document.getElementById('userDropdown');
    const logoutBtn = document.getElementById('logoutBtn');
    
    if (userMenuToggle && userDropdown) {
        userMenuToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            userDropdown.classList.toggle('active');
        });
        
        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            if (!userMenuToggle.contains(e.target) && !userDropdown.contains(e.target)) {
                userDropdown.classList.remove('active');
            }
        });
    }
    
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function(e) {
            e.preventDefault();
            logout();
        });
    }
    // Navigation tabs
    const navLinks = document.querySelectorAll('.nav-link');
    const contentSections = document.querySelectorAll('.content-section');

    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetSection = this.getAttribute('data-section');
            
            // Update active nav link
            navLinks.forEach(l => l.classList.remove('active'));
            this.classList.add('active');
            
            // Show target section
            contentSections.forEach(section => {
                section.classList.remove('active');
                if (section.id === targetSection) {
                    section.classList.add('active');
                }
            });
        });
    });

    // Mobile menu toggle
    const menuToggle = document.getElementById('menuToggle');
    const navMenu = document.querySelector('.nav-menu');
    
    if (menuToggle) {
        menuToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            navMenu.classList.toggle('active');
        });
    }

    // Close mobile menu when clicking a nav link
    navLinks.forEach(link => {
        link.addEventListener('click', function() {
            if (window.innerWidth <= 768) {
                navMenu.classList.remove('active');
            }
        });
    });

    // Helper to check if click is inside menuToggle (button or icon)
    function isClickOnMenuToggle(target) {
        return menuToggle && (target === menuToggle || menuToggle.contains(target));
    }

    // Close mobile menu when clicking/tapping outside
    document.addEventListener('click', function(e) {
        if (navMenu.classList.contains('active')) {
            if (!navMenu.contains(e.target) && !isClickOnMenuToggle(e.target)) {
                navMenu.classList.remove('active');
            }
        }
    });
    document.addEventListener('touchstart', function(e) {
        if (navMenu.classList.contains('active')) {
            if (!navMenu.contains(e.target) && !isClickOnMenuToggle(e.target)) {
                navMenu.classList.remove('active');
            }
        }
    });

    // Tab functionality
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabPanes = document.querySelectorAll('.tab-pane');

    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // Update active tab button
            tabBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            // Show target tab pane
            tabPanes.forEach(pane => {
                pane.classList.remove('active');
                if (pane.id === targetTab + '-projects' || 
                    pane.id === targetTab + '-calculator' || 
                    pane.id === targetTab + '-tracking') {
                    pane.classList.add('active');
                }
            });
        });
    });

    // Modal functionality
    window.showModal = function(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.add('active');
        }
    };

    window.closeModal = function(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.remove('active');
        }
    };

    // Close modals when clicking outside
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal')) {
            e.target.classList.remove('active');
        }
    });

    // Form submissions
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            // Basic form handling - just close modal for now
            const modal = this.closest('.modal');
            if (modal) {
                modal.classList.remove('active');
            }
            // Show success message
            alert('Action completed successfully!');
        });
    });

    // Theme toggle functionality
    const themeToggle = document.getElementById('themeToggle');
    const themeText = document.getElementById('themeText');
    
    // Check for saved theme preference or default to diurnal
    const currentTheme = localStorage.getItem('theme') || 'diurnal';
    document.documentElement.setAttribute('data-theme', currentTheme);
    updateThemeUI(currentTheme);
    
    if (themeToggle) {
        themeToggle.addEventListener('click', function(e) {
            e.preventDefault();
            const currentTheme = document.documentElement.getAttribute('data-theme');
            const newTheme = currentTheme === 'nocturnal' ? 'diurnal' : 'nocturnal';
            
            document.documentElement.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
            updateThemeUI(newTheme);
            
            // Close dropdown after theme change
            userDropdown.classList.remove('active');
        });
    }
    
    function updateThemeUI(theme) {
        const icon = themeToggle.querySelector('i');
        if (theme === 'nocturnal') {
            icon.className = 'fas fa-sun';
            themeText.textContent = 'Switch to Light';
        } else {
            icon.className = 'fas fa-moon';
            themeText.textContent = 'Switch to Dark';
        }
    }

    // Initialize some sample data
    initializeSampleData();
});

// Sample data initialization
function initializeSampleData() {
    // Sample reptiles
    const sampleReptiles = [
        {
            id: 'BP001',
            name: 'Luna',
            species: 'Ball Python',
            morph: 'Albino Piebald',
            gender: 'Female',
            status: 'active',
            weight: '1200g',
            length: '4.5ft',
            birthDate: '2022-03-15'
        },
        {
            id: 'LG001',
            name: 'Spike',
            species: 'Leopard Gecko',
            morph: 'Tremper Albino',
            gender: 'Male',
            status: 'breeding',
            weight: '65g',
            length: '8in',
            birthDate: '2021-08-20'
        },
        {
            id: 'BD001',
            name: 'Rex',
            species: 'Bearded Dragon',
            morph: 'Citrus',
            gender: 'Male',
            status: 'active',
            weight: '450g',
            length: '18in',
            birthDate: '2020-11-10'
        }
    ];

    // Populate reptiles grid
    const reptilesGrid = document.getElementById('reptilesGrid');
    if (reptilesGrid) {
                reptilesGrid.innerHTML = sampleReptiles.map(reptile => `
            <div class="reptile-card" onclick="showReptileDetail('${reptile.id}')">
                <div class="reptile-image">
                    <i class="fas fa-dragon"></i>
                </div>
                <div class="reptile-info">
                    <div class="reptile-header">
                        <div>
                            <div class="reptile-name">${reptile.name}</div>
                            <div class="reptile-species">${reptile.species}</div>
                        </div>
                        <span class="reptile-status ${reptile.status}">${reptile.status}</span>
                    </div>
                    <div class="reptile-details">
                        <div class="reptile-detail">
                            <span>ID:</span> ${reptile.id}
                        </div>
                        <div class="reptile-detail">
                            <span>Morph:</span> ${reptile.morph}
                        </div>
                        <div class="reptile-detail">
                            <span>Gender:</span> ${reptile.gender}
                        </div>
                        <div class="reptile-detail">
                            <span>Weight:</span> ${reptile.weight}
                        </div>
                    </div>
                    <div class="reptile-actions">
                        <a href="#" class="reptile-action">View</a>
                        <a href="#" class="reptile-action">Edit</a>
                        <a href="#" class="reptile-action">QR</a>
                    </div>
                </div>
            </div>
        `).join('');
    }

    // Sample breeding projects
    const breedingProjectsGrid = document.getElementById('breedingProjectsGrid');
    if (breedingProjectsGrid) {
        breedingProjectsGrid.innerHTML = `
            <div class="breeding-project">
                <div class="project-header">
                    <div class="project-name">Albino Piebald Project</div>
                    <span class="project-status">Active</span>
                </div>
                <div class="project-pair">
                    <div class="pair-member">
                        <h4>Male</h4>
                        <p>BP001 - Luna</p>
                    </div>
                    <div class="pair-member">
                        <h4>Female</h4>
                        <p>BP002 - Shadow</p>
                    </div>
                </div>
                <div class="project-dates">
                    <span>Started: Jan 15, 2025</span>
                    <span>Expected: Mar 15, 2025</span>
                </div>
                <div class="project-actions">
                    <button class="btn btn-secondary">View Details</button>
                    <button class="btn btn-primary">Log Clutch</button>
                </div>
            </div>
        `;
    }

    // Sample tasks
    const todayTasks = document.getElementById('todayTasks');
    if (todayTasks) {
        todayTasks.innerHTML = `
            <div class="task-item">
                <div class="task-checkbox"></div>
                <div class="task-content">
                    <div class="task-title">Feed Ball Python #BP001</div>
                    <div class="task-details">Medium rat (150g)</div>
                </div>
                <div class="task-time">2:00 PM</div>
            </div>
            <div class="task-item">
                <div class="task-checkbox checked"></div>
                <div class="task-content">
                    <div class="task-title">Clean Leopard Gecko Enclosure</div>
                    <div class="task-details">Spot clean and water change</div>
                </div>
                <div class="task-time">10:00 AM</div>
            </div>
        `;
    }

    // Sample inventory
    const foodInventory = document.getElementById('foodInventory');
    if (foodInventory) {
        foodInventory.innerHTML = `
            <div class="inventory-item">
                <div class="item-info">
                    <h4>Medium Rats</h4>
                    <p>Frozen feeder rodents</p>
                </div>
                <div class="item-quantity">
                    <div class="quantity">25</div>
                    <div class="unit">pieces</div>
                </div>
            </div>
            <div class="inventory-item">
                <div class="item-info">
                    <h4>Crickets</h4>
                    <p>Live feeder insects</p>
                </div>
                <div class="item-quantity">
                    <div class="quantity">100</div>
                    <div class="unit">pieces</div>
                </div>
            </div>
        `;
    }
}

// Reptile detail modal
function showReptileDetail(reptileId) {
    const modal = document.getElementById('reptileDetailModal');
    const title = document.getElementById('reptileDetailTitle');
    
    if (modal && title) {
        title.textContent = `Reptile Details - ${reptileId}`;
        modal.classList.add('active');
    }
}

// Basic utility functions
function exportReptiles() {
    alert('Exporting reptiles data...');
}

function calculateGenetics() {
    alert('Calculating genetics...');
}

function previousMonth() {
    alert('Previous month');
}

function nextMonth() {
    alert('Next month');
} 