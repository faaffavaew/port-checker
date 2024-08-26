#!/bin/bash

# Script to install and set up the ports_checker application

APP_NAME="ports_checker"
APP_DIR="/opt/$APP_NAME"

# Function to display messages
echo_message() {
    echo "==> $1"
}

# Update package lists and install required dependencies
echo_message "Updating package lists..."
sudo apt-get update

echo_message "Installing Python 3 and pip..."
sudo apt-get install -y python3 python3-pip

# Install FastAPI and Uvicorn
echo_message "Installing FastAPI and Uvicorn..."
pip3 install fastapi uvicorn

# Create application directory
echo_message "Creating application directory at $APP_DIR..."
sudo mkdir -p $APP_DIR

# Copy application files
echo_message "Copying application files..."
sudo cp -r * $APP_DIR

# Create a symlink to make the script executable from anywhere
echo_message "Creating symlink for $APP_NAME..."
sudo ln -sf $APP_DIR/$APP_NAME.py /usr/local/bin/$APP_NAME

# Make the application executable
echo_message "Making the application executable..."
sudo chmod +x /usr/local/bin/$APP_NAME

# Create a systemd service for FastAPI
echo_message "Creating systemd service for FastAPI..."
sudo bash -c "cat > /etc/systemd/system/$APP_NAME.service <<EOF
[Unit]
Description=FastAPI service for $APP_NAME
After=network.target

[Service]
User=$USER
WorkingDirectory=$APP_DIR
ExecStart=/usr/local/bin/uvicorn $APP_NAME:app --host localhost --port 54172
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd and start the service
echo_message "Starting $APP_NAME service..."
sudo systemctl daemon-reload
sudo systemctl start $APP_NAME
sudo systemctl enable $APP_NAME

echo_message "$APP_NAME installation completed. You can now use the command '$APP_NAME' to run the application."
