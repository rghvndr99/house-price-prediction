#!/bin/bash

# Local development startup script
echo "🏠 Starting House Price Predictor (Local Development)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to cleanup on exit
cleanup() {
    if [ ! -z "$FLASK_PID" ]; then
        print_status "Stopping Flask backend (PID: $FLASK_PID)..."
        kill $FLASK_PID 2>/dev/null
    fi
    if [ -d "venv" ]; then
        print_status "Deactivating virtual environment..."
        deactivate 2>/dev/null || true
    fi
}

# Set trap to cleanup on script exit
trap cleanup EXIT

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    print_error "Python3 not found. Please install Python 3.7+"
    exit 1
fi

print_status "Python version: $(python3 --version)"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    print_status "Creating virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        print_error "Failed to create virtual environment"
        exit 1
    fi
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    print_error "Failed to activate virtual environment"
    exit 1
fi

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install Python dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        print_error "Failed to install Python dependencies"
        print_status "Trying to install basic dependencies individually..."
        pip install flask flask-cors
        if [ $? -ne 0 ]; then
            print_error "Failed to install even basic dependencies. Please check your Python installation."
            exit 1
        fi
        print_warning "Only basic dependencies installed. Some features may not work."
    fi
else
    print_status "No requirements.txt found. Installing basic dependencies..."
    pip install flask flask-cors
fi

# Verify Flask installation
print_status "Verifying Flask installation..."
python3 -c "import flask; print(f'Flask version: {flask.__version__}')" 2>/dev/null
if [ $? -ne 0 ]; then
    print_error "Flask is not properly installed"
    exit 1
fi

# Check if server directory exists
if [ ! -d "server" ]; then
    print_error "Server directory not found. Please run this script from the project root."
    exit 1
fi

# Check if main.py exists
if [ ! -f "server/main.py" ]; then
    print_error "server/main.py not found. Please ensure the Flask application exists."
    exit 1
fi

# Check if port 8100 is in use and kill existing processes
print_status "Checking for existing processes on port 8100..."
if lsof -Pi :8100 -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_warning "Port 8100 is in use. Attempting to free it..."
    lsof -ti:8100 | xargs kill -9 2>/dev/null || true
    sleep 2
fi

# Start Flask backend in background
print_status "Starting Flask backend on port 8100..."
cd server
python3 main.py &
FLASK_PID=$!
cd ..

# Wait a moment for Flask to start
sleep 5

# Check if Flask is actually running
if kill -0 $FLASK_PID 2>/dev/null; then
    print_success "Backend started successfully with PID: $FLASK_PID"

    # Test if the backend is responding
    print_status "Testing backend connectivity..."
    sleep 2
    if command -v curl &> /dev/null; then
        curl -s http://localhost:8100/ > /dev/null
        if [ $? -eq 0 ]; then
            print_success "Backend is responding on http://localhost:8100"
        else
            print_warning "Backend started but may not be responding yet"
        fi
    fi
else
    print_error "Failed to start Flask backend"
    exit 1
fi

# Instructions for frontend setup
echo ""
print_status "Frontend Setup Options:"
echo ""
echo "Option 1: Simple HTTP Server (Python)"
echo "  cd client"
echo "  python3 -m http.server 8080"
echo "  Then visit: http://localhost:8080"
echo ""
echo "Option 2: Direct file access"
echo "  Open client/index.html in your web browser"
echo "  Note: You may need to update API_BASE_URL in script.js to 'http://localhost:8100'"
echo ""

# Instructions for Nginx setup (optional)
print_status "Optional: Nginx Reverse Proxy Setup"
echo "1. Install Nginx if not already installed:"
echo "   - macOS: brew install nginx"
echo "   - Ubuntu: sudo apt install nginx"
echo "   - CentOS: sudo yum install nginx"
echo ""
echo "2. Update the nginx-local.conf file with your project path:"
echo "   sed -i 's|/path/to/your/project|$(pwd)|g' nginx-local.conf"
echo ""
echo "3. Copy the configuration:"
echo "   sudo cp nginx-local.conf /etc/nginx/sites-available/house-predictor"
echo "   sudo ln -s /etc/nginx/sites-available/house-predictor /etc/nginx/sites-enabled/"
echo ""
echo "4. Test and reload Nginx:"
echo "   sudo nginx -t"
echo "   sudo systemctl reload nginx"
echo ""

# Display current status
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "🚀 Local Development Server Started!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Backend API: http://localhost:8100"
echo "📁 Frontend: Open client/index.html or serve client/ directory"
echo "🛑 To stop: Press Ctrl+C"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Keep script running and wait for user interrupt
print_status "Backend is running. Press Ctrl+C to stop..."
wait $FLASK_PID
