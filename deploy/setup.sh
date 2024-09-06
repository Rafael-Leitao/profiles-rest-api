#!/usr/bin/env bash

set -e

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/Rafael-Leitao/profiles-rest-api'

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Set Ubuntu Language
locale-gen en_GB.UTF-8

# Install Python, SQLite, and pip
echo "Installing dependencies..."
apt-get update
apt-get install -y python3-dev python3-venv sqlite3 python3-pip supervisor nginx git

# Create the project directory and clone the repository
mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

# Create a Python virtual environment
python3 -m venv $PROJECT_BASE_PATH/env

# Activate the virtual environment
source $PROJECT_BASE_PATH/env/bin/activate

# Install the required packages from requirements.txt, with a specific uwsgi version
# pip install -r $PROJECT_BASE_PATH/requirements.txt uwsgi==2.0.21

# If you encounter issues with uwsgi, consider installing an alternative like gunicorn:
pip install -r $PROJECT_BASE_PATH/requirements.txt gunicorn

# Run migrations
$PROJECT_BASE_PATH/env/bin/python $PROJECT_BASE_PATH/manage.py migrate

# Setup Supervisor to run our uwsgi (or gunicorn) process.
cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

# Setup nginx to make our application accessible.
cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx.service

echo "DONE! :)"
