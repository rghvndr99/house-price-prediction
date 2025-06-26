#!/usr/bin/env python3
"""
Simple HTTP server that serves files without caching headers
Useful for development when you want CSS/JS changes to reflect immediately
"""

import http.server
import socketserver
import os
import sys
from datetime import datetime

class RegularHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Normal caching behavior - no special headers
        super().end_headers()

    def log_message(self, format, *args):
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"[{timestamp}] {format % args}")

def main():
    port = 8081
    
    # Change to client directory
    client_dir = os.path.join(os.path.dirname(__file__), 'client')
    if os.path.exists(client_dir):
        os.chdir(client_dir)
        print(f"Serving from: {client_dir}")
    else:
        print("Client directory not found, serving from current directory")
    
    # Create server
    with socketserver.TCPServer(("", port), RegularHTTPRequestHandler) as httpd:
        print(f"🌐 Frontend Server running at http://localhost:{port}")
        print("📝 Regular HTTP server with normal caching")
        print("🛑 Press Ctrl+C to stop")
        print("-" * 50)
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 Server stopped")

if __name__ == "__main__":
    main()
