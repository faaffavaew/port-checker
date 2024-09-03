#!/bin/bash

# Variables
REPO_URL="https://raw.githubusercontent.com/justusmisha/port-checker/main/main.py"
DOCKER_COMPOSE_URL="https://raw.githubusercontent.com/justusmisha/port-checker/main/docker-compose.yml"
DOCKERFILE_URL="https://raw.githubusercontent.com/justusmisha/port-checker/main/Dockerfile"
MAIN_PY_PATH="./main.py"
DOCKER_COMPOSE_PATH="./docker-compose.yml"
DOCKERFILE_PATH="./Dockerfile"

# Check if Docker is installed; if not, install Docker
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Set up the Docker repository
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Add the current user to the docker group
    sudo usermod -aG docker $USER
fi

# Check if Docker Compose is installed; if not, install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Download the main.py file
echo "Downloading main.py..."
curl -sSL "$REPO_URL" -o "$MAIN_PY_PATH"

# Download Docker Compose configuration file
echo "Downloading docker-compose.yml..."
curl -sSL "$DOCKER_COMPOSE_URL" -o "$DOCKER_COMPOSE_PATH"

# Download Dockerfile
echo "Downloading Dockerfile..."
curl -sSL "$DOCKERFILE_URL" -o "$DOCKERFILE_PATH"

# Verify Docker Compose configuration file exists
if [ ! -f "$DOCKER_COMPOSE_PATH" ]; then
    echo "Error: $DOCKER_COMPOSE_PATH not found. Please ensure the docker-compose.yml file is present."
    exit 1
fi

# Verify Dockerfile exists
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "Error: $DOCKERFILE_PATH not found. Please ensure the Dockerfile is present."
    exit 1
fi

# Build and run the Docker container using Docker Compose
echo "Building and running Docker container..."
docker-compose up --build

echo "Docker container is running. You can access the Ports Checker application at http://localhost:54172"
