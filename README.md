# 🏠 House Price Predictor

A modern web application for predicting house prices in Bengaluru using machine learning. Built with Flask backend and vanilla JavaScript frontend.

## 🌟 Features

- **Interactive Form**: User-friendly interface with dropdowns for location, BHK, area, and bathrooms
- **Real-time Predictions**: ML-powered price predictions with confidence indicators
- **Modern UI**: Beautiful gradient design with responsive layout
- **Multiple Output Types**: Various ways to view and interact with prediction results
- **Action Buttons**: Save, share, and create new predictions

## 🚀 Quick Start

### Option 1: Complete Application (Recommended)
```bash
./start-full-app.sh
```

### Option 2: Individual Components
```bash
# Backend only
./start-local.sh

# Frontend only
./start-frontend.sh
```

## 📊 Output Types

The application provides multiple types of output and interaction methods:

### 1. **Price Card Output**
- **Large Price Display**: Main predicted value in ₹ Lakhs
- **Confidence Indicator**: Visual progress bar showing prediction confidence (75-95%)
- **Gradient Background**: Eye-catching purple/blue gradient design
- **Property Icon**: Home icon with subtitle for context

### 2. **Details Grid Output**
Three separate information cards displaying:

#### Location Card (Red Theme)
- **Icon**: 📍 Map marker
- **Content**: Selected location name (formatted)
- **Purpose**: Shows the area/locality for the prediction

#### Configuration Card (Teal Theme)
- **Icon**: 🛏️ Bed
- **Content**: BHK and bathroom count (e.g., "2 BHK, 2 Bath")
- **Purpose**: Displays property configuration

#### Area Card (Blue Theme)
- **Icon**: 📏 Ruler
- **Content**: Total area range (e.g., "1000-1250 sq ft")
- **Purpose**: Shows property size information

### 3. **Interactive Action Buttons**

#### Save Result (Primary Button)
- **Function**: Stores prediction in browser localStorage
- **Data Saved**: Price, location, config, area, timestamp
- **Feedback**: Success notification on save
- **Use Case**: Keep track of multiple property evaluations

#### Share Result (Secondary Button)
- **Native Sharing**: Uses Web Share API when available
- **Fallback**: Copies formatted text to clipboard
- **Content**: "Estimated property value: ₹X Lakhs for [Location]"
- **Use Case**: Share predictions with others

#### New Prediction (Secondary Button)
- **Function**: Resets form for another calculation
- **Actions**: Clears all inputs, hides results, focuses on location
- **Animation**: Smooth scroll to form top
- **Use Case**: Quick way to start fresh prediction

### 4. **Animation Types**

#### Staggered Card Animation
- **Sequence**: Price card → Location card → Config card → Area card
- **Timing**: 150ms delay between each card
- **Effect**: Cards slide up with fade-in
- **Duration**: 0.6s per card

#### Confidence Bar Animation
- **Type**: Width transition from 0% to actual confidence
- **Duration**: 0.8s
- **Easing**: Smooth ease transition
- **Visual**: Gold gradient fill

#### Button Hover Effects
- **Primary Buttons**: Lift up 2px with enhanced shadow
- **Secondary Buttons**: Lift up 1px with background color change
- **Timing**: 0.3s transition

### 5. **Responsive Output Variations**

#### Desktop (>768px)
- **Layout**: Three-column details grid
- **Price**: Large 3.5rem font size
- **Buttons**: Horizontal row layout
- **Confidence Bar**: 200px width

#### Tablet (≤768px)
- **Layout**: Single-column details grid
- **Price**: Medium 2.5rem font size
- **Buttons**: Vertical column layout
- **Confidence Bar**: 150px width

#### Mobile (≤480px)
- **Layout**: Optimized single column
- **Padding**: Reduced spacing
- **Font Size**: 16px minimum (prevents iOS zoom)
- **Buttons**: Full width with max-width constraint

### 6. **Data Output Format**

#### API Response Structure
```json
{
  "estimated_price": 85.5,
  "confidence": 87,
  "location": "Electronic City",
  "total_sqft": 1200,
  "bhk": 2,
  "bath": 2
}
```

#### Saved Data Structure (localStorage)
```json
{
  "price": "85.5",
  "location": "Electronic City",
  "config": "2 BHK, 2 Bath",
  "area": "1000-1250 sq ft",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

#### Share Text Format
```
Estimated property value: ₹85.5 Lakhs for Electronic City
http://localhost:8080
```

## 🎨 Design System

### Color Palette
- **Primary Gradient**: #667eea → #764ba2 (Purple/Blue)
- **Location Card**: #ff6b6b → #ee5a52 (Red)
- **Config Card**: #4ecdc4 → #44a08d (Teal)
- **Area Card**: #45b7d1 → #96c93d (Blue/Green)
- **Confidence Bar**: #ffd700 → #ffed4e (Gold)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Price Display**: 3.5rem, 700 weight
- **Card Titles**: 1.5rem, 600 weight
- **Body Text**: 1rem, 500 weight
- **Confidence**: 0.9rem, 500 weight

## 🔧 Technical Stack

- **Backend**: Flask (Python)
- **Frontend**: Vanilla JavaScript, HTML5, CSS3
- **ML Model**: Scikit-learn (Pickle format)
- **Styling**: CSS Grid, Flexbox, CSS Gradients
- **Icons**: Font Awesome 6
- **Animations**: CSS Transitions & Transforms

## 📱 Browser Support

- **Modern Browsers**: Chrome 80+, Firefox 75+, Safari 13+, Edge 80+
- **Features Used**: CSS Grid, Flexbox, CSS Variables, Web Share API
- **Fallbacks**: Clipboard API fallback for sharing

## 🎯 Use Cases

1. **Real Estate Agents**: Quick property valuations for clients
2. **Home Buyers**: Estimate fair prices before negotiations
3. **Property Investors**: Evaluate investment opportunities
4. **Developers**: Integrate pricing into property platforms
5. **Researchers**: Study Bengaluru real estate trends

---

**Built with ❤️ for accurate house price predictions in Bengaluru**
