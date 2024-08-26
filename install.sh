#!/bin/bash

# Variables
REPO_URL="https://raw.githubusercontent.com/justusmisha/port-checker/main/main.py"
INSTALL_DIR="/opt/ports_checker"
SERVICE_FILE="/etc/systemd/system/ports_checker.service"
COMMAND_PATH="/usr/local/bin/ports_checker"

# Update package list and install prerequisites
echo "Updating package list and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl software-properties-common

# Add the deadsnakes PPA for Python 3.10
echo "Adding deadsnakes PPA for Python 3.10..."
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update

# Install Python 3.10 and pip
echo "Installing Python 3.10 and pip..."
sudo apt-get install -y python3.10 python3.10-venv python3.10-distutils
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3.10 get-pip.py

# Create a virtual environment with Python 3.10
echo "Creating a virtual environment with Python 3.10..."
python3.10 -m venv /opt/ports_checker/venv

# Activate the virtual environment and install required Python packages
echo "Installing FastAPI and Uvicorn..."
source /opt/ports_checker/venv/bin/activate
pip install --upgrade pip
pip install fastapi uvicorn

# Create directory and download application files
echo "Creating directory and downloading main.py..."
sudo mkdir -p "$INSTALL_DIR"
curl -sSL "$REPO_URL" -o "$INSTALL_DIR/main.py"

# Make the script executable
sudo chmod +x "$INSTALL_DIR/main.py"

# Create a systemd service file
echo "Creating systemd service file..."
sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=FastAPI service for ports_checker
After=network.target

[Service]
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 54172
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start the service
echo "Reloading systemd and starting the service..."
sudo systemctl daemon-reload
sudo systemctl start ports_checker
sudo systemctl enable ports_checker

# Create a command to run the script
echo "Creating command for myapp..."
echo "#!/bin/bash
source $INSTALL_DIR/venv/bin/activate
python3 $INSTALL_DIR/main.py \"\$@\"
" | sudo tee $COMMAND_PATH > /dev/null
sudo chmod +x $COMMAND_PATH

echo "Installation complete. You can now use the 'myapp' command and the Ports Checker service is running."
