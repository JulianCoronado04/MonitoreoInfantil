# Use Python 3.11 slim to ensure prebuilt wheels are available for common extensions
FROM python:3.11-slim

# Prevent prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system packages required for msodbcsql and building extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       gnupg2 \
       apt-transport-https \
       build-essential \
       unixodbc-dev \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft package repository for ODBC driver and tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 mssql-tools unixodbc-dev \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'export PATH="${PATH}:/opt/mssql-tools/bin"' > /etc/profile.d/mssql.sh

# Create app directory
WORKDIR /app

# Copy requirements and install Python deps first (cache benefits)
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install -r /app/requirements.txt

# Copy application code
COPY . /app

# Expose port used by Flask / Gunicorn
EXPOSE 5000

# Run the app with gunicorn for production-like behavior
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
