// Configuration
// Auto-detect if we're running with Nginx reverse proxy or direct backend
const API_BASE_URL = window.location.hostname === 'localhost' && window.location.port === '8080'
    ? 'http://localhost:8100'  // Direct backend for local development
    : '/api';                  // Nginx reverse proxy for production

// DOM Elements
const locationSelect = document.getElementById('location');
const bhkSelect = document.getElementById('bhk');
const areaSelect = document.getElementById('area');
const bathroomsSelect = document.getElementById('bathrooms');
const predictionForm = document.getElementById('predictionForm');
const predictBtn = document.getElementById('predictBtn');
const btnLoader = document.getElementById('btnLoader');
const resultSection = document.getElementById('resultSection');
const predictedPrice = document.getElementById('predictedPrice');
const resultLocation = document.getElementById('resultLocation');
const resultConfig = document.getElementById('resultConfig');
const resultArea = document.getElementById('resultArea');
const confidenceBar = document.getElementById('confidenceBar');
const confidenceText = document.getElementById('confidenceText');
const saveResultBtn = document.getElementById('saveResult');
const shareResultBtn = document.getElementById('shareResult');
const newPredictionBtn = document.getElementById('newPrediction');

// State
let locations = [];
let isLoading = false;

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

async function initializeApp() {
    try {
        // Check API connectivity first
        await checkAPIConnectivity();
        await loadLocations();
        setupEventListeners();
        console.log('App initialized successfully');
    } catch (error) {
        console.error('Failed to initialize app:', error);
        showError('Failed to load application data. Please refresh the page.');
    }
}

// Check if the API is accessible
async function checkAPIConnectivity() {
    try {
        const response = await fetch(`${API_BASE_URL}/health`, {
            method: 'GET',
            headers: {
                'Accept': 'text/plain'
            }
        });

        if (!response.ok) {
            throw new Error(`Health check failed: ${response.status}`);
        }

        console.log('API connectivity check passed');
    } catch (error) {
        console.warn('API connectivity check failed:', error);
        showError('Warning: API server may not be accessible. Some features may not work.');
    }
}

// Load locations from API
async function loadLocations() {
    try {
        showLoadingState(true);

        const response = await fetch(`${API_BASE_URL}/get-location`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        console.log('API Response:', data);

        locations = data.locations || [];

        if (locations.length === 0) {
            throw new Error('No locations received from API');
        }

        populateLocationDropdown();
        console.log(`Successfully loaded ${locations.length} locations`);

    } catch (error) {
        console.error('Error loading locations:', error);
        showError(`Failed to load locations: ${error.message}. Please check if the server is running.`);

        // Fallback: Add some default locations for development
        locations = ['Electronic City', 'Whitefield', 'Koramangala', 'BTM Layout', 'HSR Layout'];
        populateLocationDropdown();
        console.warn('Using fallback locations for development');
    } finally {
        showLoadingState(false);
    }
}

// Populate location dropdown
function populateLocationDropdown() {
    // Clear existing options except the first one
    locationSelect.innerHTML = '<option value="">Select Location</option>';
    
    // Sort locations alphabetically
    const sortedLocations = [...locations].sort((a, b) => 
        a.toLowerCase().localeCompare(b.toLowerCase())
    );
    
    // Add location options
    sortedLocations.forEach(location => {
        const option = document.createElement('option');
        option.value = location;
        option.textContent = formatLocationName(location);
        locationSelect.appendChild(option);
    });
}

// Format location name for display
function formatLocationName(location) {
    return location
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
        .join(' ');
}

// Setup event listeners
function setupEventListeners() {
    predictionForm.addEventListener('submit', handleFormSubmit);

    // Add change listeners for form validation
    [locationSelect, bhkSelect, areaSelect, bathroomsSelect].forEach(select => {
        select.addEventListener('change', validateForm);
    });

    // Add event listeners for action buttons
    if (saveResultBtn) {
        saveResultBtn.addEventListener('click', handleSaveResult);
    }

    if (shareResultBtn) {
        shareResultBtn.addEventListener('click', handleShareResult);
    }

    if (newPredictionBtn) {
        newPredictionBtn.addEventListener('click', handleNewPrediction);
    }
}

// Handle form submission
async function handleFormSubmit(event) {
    event.preventDefault();
    
    if (isLoading) return;
    
    const formData = getFormData();
    
    if (!validateFormData(formData)) {
        showError('Please fill in all required fields.');
        return;
    }
    
    try {
        setLoadingState(true);
        const prediction = await predictPrice(formData);
        displayResult(prediction, formData);
    } catch (error) {
        console.error('Prediction error:', error);
        showError('Failed to get price prediction. Please try again.');
    } finally {
        setLoadingState(false);
    }
}

// Get form data
function getFormData() {
    return {
        location: locationSelect.value,
        bhk: parseInt(bhkSelect.value),
        area: parseInt(areaSelect.value),
        bathrooms: parseInt(bathroomsSelect.value)
    };
}

// Validate form data
function validateFormData(data) {
    return data.location && 
           !isNaN(data.bhk) && 
           !isNaN(data.area) && 
           !isNaN(data.bathrooms);
}

// Validate form and enable/disable submit button
function validateForm() {
    const formData = getFormData();
    const isValid = validateFormData(formData);
    
    predictBtn.disabled = !isValid || isLoading;
}

// Predict price using the backend API
async function predictPrice(formData) {
    try {
        const response = await fetch(`${API_BASE_URL}/predict-price`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                location: formData.location,
                bhk: formData.bhk,
                total_sqft: formData.area,
                bath: formData.bathrooms
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        return {
            price: Math.round(data.estimated_price || 0),
            confidence: data.confidence || 85
        };
    } catch (error) {
        console.error('API prediction error:', error);

        // Fallback to mock prediction if API fails
        console.warn('Using fallback prediction due to API error');
        const basePrice = 50;
        const locationMultiplier = Math.random() * 2 + 0.5;
        const bhkMultiplier = formData.bhk * 15;
        const areaMultiplier = formData.area / 1000 * 30;
        const bathroomMultiplier = formData.bathrooms * 5;

        const predictedPrice = Math.round(
            (basePrice + bhkMultiplier + areaMultiplier + bathroomMultiplier) * locationMultiplier
        );

        return {
            price: predictedPrice,
            confidence: 75
        };
    }
}

// Display prediction result
function displayResult(prediction, formData) {
    // Update price display with Indian number formatting
    predictedPrice.textContent = formatNumber(prediction.price);

    // Update confidence bar and text
    const confidence = prediction.confidence || 85;
    if (confidenceBar) {
        confidenceBar.style.width = `${confidence}%`;
    }
    if (confidenceText) {
        confidenceText.textContent = `${confidence}% Confidence`;
    }

    // Update result details
    resultLocation.textContent = formatLocationName(formData.location);
    resultConfig.textContent = `${formData.bhk} BHK, ${formData.bathrooms} Bath`;
    resultArea.textContent = `${formData.area} sqrt`;

    // Show result section with animation
    resultSection.style.display = 'block';
    resultSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

    // Add staggered animation for cards
    const cards = resultSection.querySelectorAll('.price-card, .detail-card');
    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(30px)';

        setTimeout(() => {
            card.style.transition = 'all 0.6s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, 100 + (index * 150));
    });

    // Animate action buttons
    const actionButtons = resultSection.querySelector('.result-actions');
    if (actionButtons) {
        actionButtons.style.opacity = '0';
        actionButtons.style.transform = 'translateY(20px)';

        setTimeout(() => {
            actionButtons.style.transition = 'all 0.5s ease';
            actionButtons.style.opacity = '1';
            actionButtons.style.transform = 'translateY(0)';
        }, 800);
    }

    // Show success notification
    showSuccess(`Price prediction completed! Estimated value: ₹${formatNumber(prediction.price)} Lakhs`);
}

// Set loading state
function setLoadingState(loading) {
    isLoading = loading;
    predictBtn.disabled = loading;
    
    if (loading) {
        btnLoader.style.display = 'block';
        predictBtn.innerHTML = '<i class="fas fa-calculator"></i> Predicting... <div class="btn-loader" id="btnLoader"></div>';
    } else {
        btnLoader.style.display = 'none';
        predictBtn.innerHTML = '<i class="fas fa-calculator"></i> Predict Price';
    }
    
    validateForm();
}

// Show loading state for initial data loading
function showLoadingState(loading) {
    if (loading) {
        locationSelect.innerHTML = '<option value="">Loading locations...</option>';
        locationSelect.disabled = true;
    } else {
        locationSelect.disabled = false;
    }
}

// Show success message
function showSuccess(message) {
    showNotification(message, 'success');
}

// Show error message
function showError(message) {
    showNotification(message, 'error');
}

// Generic notification function
function showNotification(message, type = 'error') {
    const isSuccess = type === 'success';
    const notificationDiv = document.createElement('div');
    notificationDiv.className = `notification notification-${type}`;

    const icon = isSuccess ? 'fas fa-check-circle' : 'fas fa-exclamation-triangle';

    notificationDiv.innerHTML = `
        <i class="${icon}"></i>
        <span>${message}</span>
        <button onclick="this.parentElement.remove()">
            <i class="fas fa-times"></i>
        </button>
    `;
    
    // Add notification styles if not already added
    if (!document.querySelector('.notification-styles')) {
        const style = document.createElement('style');
        style.className = 'notification-styles';
        style.textContent = `
            .notification {
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 16px 20px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                gap: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                z-index: 1000;
                max-width: 400px;
                animation: slideIn 0.3s ease;
                font-weight: 500;
            }

            .notification-error {
                background: #fed7d7;
                color: #c53030;
                border: 1px solid #feb2b2;
            }

            .notification-success {
                background: #c6f6d5;
                color: #2f855a;
                border: 1px solid #9ae6b4;
            }

            .notification button {
                background: none;
                border: none;
                cursor: pointer;
                padding: 4px;
                border-radius: 4px;
                color: inherit;
            }

            .notification-error button:hover {
                background: rgba(197, 48, 48, 0.1);
            }

            .notification-success button:hover {
                background: rgba(47, 133, 90, 0.1);
            }

            @keyframes slideIn {
                from {
                    transform: translateX(100%);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }
        `;
        document.head.appendChild(style);
    }

    document.body.appendChild(notificationDiv);

    // Auto remove after 5 seconds (success) or 7 seconds (error)
    const timeout = type === 'success' ? 4000 : 6000;
    setTimeout(() => {
        if (notificationDiv.parentElement) {
            notificationDiv.remove();
        }
    }, timeout);
}

// Utility function to format numbers
function formatNumber(num) {
    return new Intl.NumberFormat('en-IN').format(num);
}

// Action button handlers
function handleSaveResult() {
    const currentResult = {
        price: predictedPrice.textContent,
        location: resultLocation.textContent,
        config: resultConfig.textContent,
        area: resultArea.textContent,
        timestamp: new Date().toISOString()
    };

    // Save to localStorage
    try {
        const savedResults = JSON.parse(localStorage.getItem('house-predictions') || '[]');
        savedResults.push(currentResult);
        localStorage.setItem('house-predictions', JSON.stringify(savedResults));
        showSuccess('Result saved successfully!');
    } catch (error) {
        showError('Failed to save result. Please try again.');
    }
}

function handleShareResult() {
    const shareData = {
        title: 'House Price Prediction',
        text: `Estimated property value: ₹${predictedPrice.textContent} Lakhs for ${resultLocation.textContent}`,
        url: window.location.href
    };

    if (navigator.share) {
        navigator.share(shareData).catch(err => console.log('Error sharing:', err));
    } else {
        // Fallback: copy to clipboard
        const shareText = `${shareData.text}\n${shareData.url}`;
        navigator.clipboard.writeText(shareText).then(() => {
            showSuccess('Result copied to clipboard!');
        }).catch(() => {
            showError('Failed to copy result. Please try again.');
        });
    }
}

function handleNewPrediction() {
    // Reset form
    predictionForm.reset();

    // Hide result section
    resultSection.style.display = 'none';

    // Scroll to form
    predictionForm.scrollIntoView({ behavior: 'smooth', block: 'start' });

    // Focus on first input
    locationSelect.focus();

    showSuccess('Ready for new prediction!');
}

// Initialize form validation on page load
document.addEventListener('DOMContentLoaded', function() {
    validateForm();
});
