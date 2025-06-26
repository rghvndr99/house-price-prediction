# 🏠 House Price Predictor - How to Start

A complete guide to set up and run the House Price Predictor application with Nginx reverse proxy.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start (Docker)](#quick-start-docker)
- [Local Development Setup](#local-development-setup)
- [Manual Setup](#manual-setup)
- [Troubleshooting](#troubleshooting)
- [API Endpoints](#api-endpoints)
- [Project Structure](#project-structure)

## 🔧 Prerequisites

### Required Software

1. **Docker & Docker Compose** (Recommended)
   - [Install Docker](https://docs.docker.com/get-docker/)
   - [Install Docker Compose](https://docs.docker.com/compose/install/)

2. **Alternative: Local Setup**
   - Python 3.7+ with pip
   - Nginx (optional for reverse proxy)
   - Node.js (optional, for additional frontend tools)

### System Requirements

- **RAM**: Minimum 2GB, Recommended 4GB+
- **Storage**: At least 1GB free space
- **OS**: Linux, macOS, or Windows with WSL2

## 🚀 Quick Start (Docker)

### Option 1: Automated Setup (Easiest)

```bash
# Clone or navigate to the project directory
cd house-predict

# Run the automated setup script
./setup.sh
```

This script will:
- ✅ Check Docker installation
- ✅ Build and start all services
- ✅ Set up Nginx reverse proxy
- ✅ Display access URLs

**Access URLs:**
- 🌐 **Frontend**: http://localhost
- 🔧 **API**: http://localhost/api/
- 📊 **Health Check**: http://localhost/health

### Option 2: Manual Docker Commands

```bash
# Build and start services
docker-compose up --build -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 💻 Local Development Setup

### Step 1: Install Python Dependencies

```bash
# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Start Flask Backend

```bash
# Navigate to server directory
cd server

# Start Flask application
python main.py
```

The backend will be available at: http://localhost:8100

### Step 3: Serve Frontend

**Option A: Simple HTTP Server**
```bash
# Navigate to client directory
cd client

# Python 3
python -m http.server 8080

# Python 2
python -m SimpleHTTPServer 8080
```

**Option B: Using Node.js**
```bash
# Install a simple server
npm install -g http-server

# Navigate to client directory
cd client

# Start server
http-server -p 8080
```

Frontend will be available at: http://localhost:8080

### Step 4: Configure API Calls

If running locally without Nginx, update the API base URL in `client/script.js`:

```javascript
// For local development without Nginx
const API_BASE_URL = 'http://localhost:8100';
```

## 🔧 Manual Setup

### 1. Flask Backend Setup

```bash
# Install Python dependencies
pip install flask flask-cors numpy pandas scikit-learn

# Start the backend
cd server
python main.py
```

### 2. Nginx Configuration (Optional)

```bash
# Install Nginx
# Ubuntu/Debian
sudo apt update && sudo apt install nginx

# macOS
brew install nginx

# CentOS/RHEL
sudo yum install nginx

# Copy configuration
sudo cp nginx-local.conf /etc/nginx/sites-available/house-predictor
sudo ln -s /etc/nginx/sites-available/house-predictor /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Frontend Setup

Simply open `client/index.html` in a web browser, or serve it using any web server.

## 🐛 Troubleshooting

### Common Issues

#### 1. Docker Issues

**Problem**: `docker-compose` command not found
```bash
# Solution: Install Docker Compose
pip install docker-compose
# OR
sudo apt install docker-compose
```

**Problem**: Permission denied
```bash
# Solution: Add user to docker group
sudo usermod -aG docker $USER
# Then logout and login again
```

#### 2. Port Conflicts

**Problem**: Port 80 or 8100 already in use
```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :8100

# Kill the process or change ports in docker-compose.yml
```

#### 3. API Connection Issues

**Problem**: Frontend can't connect to API

**Solutions**:
1. Check if backend is running: `curl http://localhost:8100/`
2. Verify Nginx is proxying correctly: `curl http://localhost/api/`
3. Check browser console for CORS errors
4. Ensure API_BASE_URL is correct in `script.js`

#### 4. Missing Dependencies

**Problem**: Python modules not found
```bash
# Solution: Install missing packages
pip install -r requirements.txt

# Or install individually
pip install flask flask-cors numpy pandas scikit-learn
```

### Logs and Debugging

```bash
# Docker logs
docker-compose logs backend
docker-compose logs nginx

# Check service status
docker-compose ps

# Access container shell
docker-compose exec backend bash
docker-compose exec nginx sh
```

## 📡 API Endpoints

### Backend Endpoints (Flask)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| GET | `/get-location` | Get available locations |
| POST | `/predict-price` | Predict house price |

### Frontend Endpoints (Nginx)

| URL | Description |
|-----|-------------|
| `/` | Main application |
| `/api/*` | Proxied to Flask backend |
| `/health` | Nginx health check |

### Sample API Calls

**Get Locations:**
```bash
curl http://localhost/api/get-location
```

**Predict Price:**
```bash
curl -X POST http://localhost/api/predict-price \
  -H "Content-Type: application/json" \
  -d '{
    "location": "Electronic City",
    "bhk": 2,
    "total_sqft": 1200,
    "bath": 2
  }'
```

## 📁 Project Structure

```
house-predict/
├── client/                 # Frontend files
│   ├── index.html         # Main HTML file
│   ├── styles.css         # CSS styling
│   └── script.js          # JavaScript logic
├── server/                # Backend files
│   ├── main.py           # Flask application
│   └── utils/            # Utility modules
│       └── locations.py  # Location handling
├── model/                # ML model files
│   ├── columns.json      # Feature columns
│   └── dwelling_model.pickle # Trained model
├── nginx.conf            # Nginx configuration
├── docker-compose.yml    # Docker services
├── Dockerfile.backend    # Backend container
├── requirements.txt      # Python dependencies
├── setup.sh             # Automated setup script
└── how-to-start.md      # This file
```

## 🎯 Next Steps

1. **Customize the Model**: Replace the mock prediction with your trained ML model
2. **Add Features**: Implement additional property features
3. **Enhance UI**: Customize the frontend design
4. **Deploy**: Set up production deployment with SSL
5. **Monitor**: Add logging and monitoring tools

## 📞 Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review logs using the commands provided
3. Ensure all prerequisites are installed
4. Verify network connectivity and port availability

---

**Happy Predicting! 🏠💰**
