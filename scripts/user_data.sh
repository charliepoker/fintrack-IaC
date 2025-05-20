#!/bin/bash

# --- 1. Update and install required packages ---
echo "Updating apt packages..."
sudo apt-get update -y
echo "Installing python3, pip, venv, git..."
sudo apt-get install -y python3 python3-pip python3-venv git
echo "Package installation complete."

# Create a directory for the application
APP_DIR="/home/ubuntu/fintrack"
sudo mkdir -p "$APP_DIR"
sudo chown ubuntu:ubuntu "$APP_DIR"
cd "$APP_DIR"

# Clone the repository 
git clone https://github.com/charliepoker/fintrack.git .
sudo chown -R ubuntu:ubuntu "$APP_DIR" 

# Create a virtual environment and activate it
VENV_DIR="$APP_DIR/venv"
sudo -u ubuntu python3 -m venv "$VENV_DIR"

# Install application dependencies 
sudo -u ubuntu "$VENV_DIR/bin/pip" install -r requirements.txt



# Start the Flask app using Gunicorn as ubuntu user
echo "Attempting to start Gunicorn (NOT as daemon for debugging)..."

sudo -u ubuntu bash -c "
    set -e; \
    echo 'Inside sudo -u ubuntu bash -c block'; \
    cd \"$APP_DIR\"; \
    echo \"Current directory for Gunicorn: \$(pwd)\"; \
    echo 'Activating venv...'; \
    source \"$VENV_DIR/bin/activate\"; \
    echo 'Venv activated. which python: \$(which python), which gunicorn: \$(which gunicorn)'; \
    echo 'Running Gunicorn...'; \
    gunicorn app:app --bind 0.0.0.0:5001 --workers 2 --access-logfile - --error-logfile -
"

