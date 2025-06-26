#!/bin/bash

# Complete application startup script (Backend + Frontend)
echo "🏠 Starting Complete House Price Predictor Application"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
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

print_header() {
    echo -e "${PURPLE}[SETUP]${NC} $1"
}

# Function to cleanup on exit
cleanup() {
    echo ""
    print_status "Shutting down application..."
    
    if [ ! -z "$FRONTEND_PID" ]; then
        print_status "Stopping frontend server (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID 2>/dev/null
    fi
    
    if [ ! -z "$BACKEND_PID" ]; then
        print_status "Stopping backend server (PID: $BACKEND_PID)..."
        kill $BACKEND_PID 2>/dev/null
    fi
    
    if [ -d "venv" ]; then
        print_status "Deactivating virtual environment..."
        deactivate 2>/dev/null || true
    fi
    
    print_success "Application stopped successfully!"
}

# Set trap to cleanup on script exit
trap cleanup EXIT

# Check prerequisites
print_header "Checking Prerequisites..."

if ! command -v python3 &> /dev/null; then
    print_error "Python3 not found. Please install Python 3.7+"
    exit 1
fi

if [ ! -d "server" ] || [ ! -f "server/main.py" ]; then
    print_error "Backend files not found. Please ensure server/main.py exists."
    exit 1
fi

if [ ! -d "client" ] || [ ! -f "client/index.html" ]; then
    print_error "Frontend files not found. Please ensure client/index.html exists."
    exit 1
fi

print_success "All prerequisites met!"

# Setup Python environment
print_header "Setting up Python Environment..."

if [ ! -d "venv" ]; then
    print_status "Creating virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        print_error "Failed to create virtual environment"
        exit 1
    fi
fi

print_status "Activating virtual environment..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    print_error "Failed to activate virtual environment"
    exit 1
fi

print_status "Upgrading pip..."
pip install --upgrade pip > /dev/null 2>&1

# Install dependencies
print_header "Installing Dependencies..."

if [ -f "requirements.txt" ]; then
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        print_warning "Full requirements failed. Installing basic dependencies..."
        pip install flask flask-cors > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            print_error "Failed to install even basic dependencies"
            exit 1
        fi
    fi
else
    print_status "Installing basic dependencies..."
    pip install flask flask-cors > /dev/null 2>&1
fi

print_success "Dependencies installed!"

# Clear ports
print_header "Preparing Ports..."

if lsof -Pi :8100 -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_status "Clearing port 8100..."
    lsof -ti:8100 | xargs kill -9 2>/dev/null || true
    sleep 1
fi

if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_status "Clearing port 8080..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    sleep 1
fi

# Start Backend
print_header "Starting Backend Server..."

cd server
python3 main.py > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

sleep 3

if kill -0 $BACKEND_PID 2>/dev/null; then
    print_success "Backend started successfully (PID: $BACKEND_PID)"
    
    # Test backend
    if command -v curl &> /dev/null; then
        if curl -s http://localhost:8100/ > /dev/null 2>&1; then
            print_success "Backend is responding on http://localhost:8100"
        else
            print_warning "Backend may still be starting up..."
        fi
    fi
else
    print_error "Failed to start backend server"
    print_status "Check backend.log for details"
    exit 1
fi

# Start Frontend
print_header "Starting Frontend Server..."

cd client
python3 -m http.server 8080 > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

sleep 2

if kill -0 $FRONTEND_PID 2>/dev/null; then
    print_success "Frontend started successfully (PID: $FRONTEND_PID)"
    
    # Test frontend
    if command -v curl &> /dev/null; then
        if curl -s http://localhost:8080/ > /dev/null 2>&1; then
            print_success "Frontend is responding on http://localhost:8080"
        else
            print_warning "Frontend may still be starting up..."
        fi
    fi
else
    print_error "Failed to start frontend server"
    print_status "Check frontend.log for details"
    exit 1
fi

# Display final status
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "🚀 House Price Predictor Application Started!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Frontend Application: http://localhost:8080"
echo "🔧 Backend API: http://localhost:8100"
echo "📊 API Endpoints:"
echo "   • GET  /api/get-location  - Get available locations"
echo "   • POST /api/predict-price - Predict house price"
echo ""
echo "📱 Access from other devices:"
echo "   • Frontend: http://$(hostname -I | awk '{print $1}' 2>/dev/null || echo 'YOUR_IP'):8080"
echo "   • Backend:  http://$(hostname -I | awk '{print $1}' 2>/dev/null || echo 'YOUR_IP'):8100"
echo ""
echo "📝 Logs:"
echo "   • Backend:  tail -f backend.log"
echo "   • Frontend: tail -f frontend.log"
echo ""
echo "🛑 To stop: Press Ctrl+C"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Open browser automatically
if command -v open &> /dev/null; then
    print_status "Opening application in browser..."
    sleep 2
    open http://localhost:8080
elif command -v xdg-open &> /dev/null; then
    print_status "Opening application in browser..."
    sleep 2
    xdg-open http://localhost:8080
fi

# Keep script running
print_status "Application is running. Press Ctrl+C to stop both servers..."
wait
