#!/bin/bash

# Frontend server startup script
echo "🌐 Starting House Price Predictor Frontend Server"

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
    if [ ! -z "$FRONTEND_PID" ]; then
        print_status "Stopping frontend server (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID 2>/dev/null
    fi
}

# Set trap to cleanup on script exit
trap cleanup EXIT

# Check if client directory exists
if [ ! -d "client" ]; then
    print_error "Client directory not found. Please run this script from the project root."
    exit 1
fi

# Check if index.html exists
if [ ! -f "client/index.html" ]; then
    print_error "client/index.html not found. Please ensure the frontend files exist."
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    print_error "Python3 not found. Please install Python 3.7+"
    exit 1
fi

print_status "Python version: $(python3 --version)"

# Check if port 8080 is in use and kill existing processes
print_status "Checking for existing processes on port 8080..."
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_warning "Port 8080 is in use. Attempting to free it..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    sleep 2
fi

# Check if backend is running
print_status "Checking backend connectivity..."
if command -v curl &> /dev/null; then
    if curl -s http://localhost:8100/ > /dev/null 2>&1; then
        print_success "Backend is running on http://localhost:8100"
    else
        print_warning "Backend not detected on port 8100. You may need to start it first."
        echo "  Run: ./start-local.sh"
    fi
else
    print_warning "curl not available. Cannot check backend status."
fi

# Start frontend server
print_status "Starting frontend server on port 8080..."
cd client

# Start Python HTTP server in background
python3 -m http.server 8080 &
FRONTEND_PID=$!
cd ..

# Wait a moment for server to start
sleep 3

# Check if frontend server is actually running
if kill -0 $FRONTEND_PID 2>/dev/null; then
    print_success "Frontend server started successfully with PID: $FRONTEND_PID"
    
    # Test if the frontend is responding
    print_status "Testing frontend connectivity..."
    sleep 2
    if command -v curl &> /dev/null; then
        if curl -s http://localhost:8080/ > /dev/null 2>&1; then
            print_success "Frontend is responding on http://localhost:8080"
        else
            print_warning "Frontend started but may not be responding yet"
        fi
    fi
else
    print_error "Failed to start frontend server"
    exit 1
fi

# Display current status
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "🌐 Frontend Server Started!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Frontend: http://localhost:8080"
echo "🔧 Backend API: http://localhost:8100"
echo "📱 Access from other devices: http://$(hostname -I | awk '{print $1}'):8080"
echo "🛑 To stop: Press Ctrl+C"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Open browser automatically (optional)
if command -v open &> /dev/null; then
    print_status "Opening browser..."
    open http://localhost:8080
elif command -v xdg-open &> /dev/null; then
    print_status "Opening browser..."
    xdg-open http://localhost:8080
fi

# Keep script running and wait for user interrupt
print_status "Frontend server is running. Press Ctrl+C to stop..."
wait $FRONTEND_PID
