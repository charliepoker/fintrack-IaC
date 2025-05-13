#!/bin/bash
# Ensure this script exits on any error
set -e

# Redirect all output of this script (stdout and stderr) to a log file
# This is the MOST IMPORTANT log file to check first.
exec > /tmp/my_user_data_debug.log 2>&1

echo "--- Starting user_data script ---"
date

# --- 1. Update and install required packages ---
echo "Updating apt packages..."
sudo apt-get update -y
echo "Installing python3, pip, venv, git..."
sudo apt-get install -y python3 python3-pip python3-venv git
echo "Package installation complete."

# --- 2. Create a directory for the application ---
APP_DIR="/home/ubuntu/fintrack"
echo "Creating application directory: $APP_DIR"
# cd /home/ubuntu # Not strictly necessary if using absolute paths
sudo mkdir -p "$APP_DIR"
echo "Setting ownership of $APP_DIR to ubuntu:ubuntu"
sudo chown ubuntu:ubuntu "$APP_DIR"
cd "$APP_DIR"
echo "Current directory: $(pwd)"

# --- 3. Clone the repository ---
echo "Cloning repository into current directory..."
# Ensure the directory is empty or git clone might fail if re-run
# For a fresh VM, cloning into . should be fine.
# Consider removing existing content if this script might re-run on the same dir:
# sudo rm -rf .git # Be careful with rm -rf
# sudo find . -mindepth 1 -delete # Be careful with find -delete
git clone https://github.com/charliepoker/fintrack.git .
echo "Setting ownership of all cloned files in $APP_DIR to ubuntu:ubuntu"
sudo chown -R ubuntu:ubuntu "$APP_DIR" # Recursive chown after clone
echo "Repository cloned."

# --- 4. Create a virtual environment and activate it ---
VENV_DIR="$APP_DIR/venv"
echo "Creating virtual environment at $VENV_DIR (as ubuntu user)"
sudo -u ubuntu python3 -m venv "$VENV_DIR"
echo "Virtual environment created."

# --- 5. Install application dependencies ---
# IMPORTANT: Run pip install as the ubuntu user using the venv's pip
echo "Installing application dependencies from requirements.txt (as ubuntu user)"
sudo -u ubuntu "$VENV_DIR/bin/pip" install -r requirements.txt
echo "Application dependencies installation attempt finished."

# --- 6. Ensure log directory for the Python app exists and is writable ---
APP_LOG_DIR="$APP_DIR/logs"
echo "Creating application log directory: $APP_LOG_DIR"
sudo -u ubuntu mkdir -p "$APP_LOG_DIR" # Create as ubuntu user
echo "App log directory $APP_LOG_DIR should now exist."

# --- 7. Start the Flask app using Gunicorn (as ubuntu user, NO DAEMON for debugging) ---
echo "Attempting to start Gunicorn (NOT as daemon for debugging)..."
# Run Gunicorn in the foreground so its output goes to /tmp/my_user_data_debug.log
# Ensure all commands for gunicorn are run as the 'ubuntu' user
# and within the context of the activated venv.
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
# The above line uses --access-logfile - and --error-logfile - to send Gunicorn logs to stdout/stderr
# which will be captured by /tmp/my_user_data_debug.log

echo "Gunicorn command has been executed (or attempted)."
echo "If Gunicorn started successfully in foreground, this script will hang here until Gunicorn is stopped."
echo "If Gunicorn failed, errors should be above this line in /tmp/my_user_data_debug.log."

echo "--- User_data script finished or Gunicorn is running in foreground ---"
date