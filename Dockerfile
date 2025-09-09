# Use an official Python runtime based on Debian Bookworm for better package compatibility
FROM python:3.11-slim-bookworm

# Set the working directory in the container
WORKDIR /app

# Install updated system dependencies required by modern versions of pyppeteer/chromium
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Puppeteer's dependencies
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libexpat1 \
    libgbm1 \
    libgdk-pixbuf-2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    # Other useful packages
    ca-certificates \
    fonts-liberation \
    lsb-release \
    wget \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Install any needed packages specified in requirements.txt   
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application's code into the container  
COPY . .

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Define environment variables
ENV FLASK_APP=app.py

# Run app.py when the container launches using Gunicorn       
CMD ["gunicorn", "-k", "gevent", "--bind", "0.0.0.0:8000", "app:app"]