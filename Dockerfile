# Use the official Python image from the Docker Hub
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file to the working directory
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire contents of the local directory to the working directory in the container
COPY . .

# Expose the port the app runs on
EXPOSE 54172

# Run the main.py file when the container launches
CMD ["python", "main.py"]
