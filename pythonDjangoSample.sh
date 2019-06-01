#!/bin/bash
# Austin Grismore
# 5/22/2019
#
# - Run script via root/sudo. Assuming fresh OS install with no dependencies
# in place. (installing python, django and git)
# - For cd/install test failures, just exit, because I didn't have enough
# time to tune the script to my usual liking. Would probably be better to return
# out of functions, and then retry installs or directory navigation.
#
# Instructions: Using any of the examples, create a script in bash to
# automate installing the dependencies, running migrations (if the
# framework requires it), and running the server:
#

function installPython() {
# install python.
yum update
# Grab it all, just for safety.
yum install -y python python-libs python-devel python-pip
# Check the python version, don't advance unless we have it.
if [ "$(command -v python3.6)" ]; then
  printf "%s - Python installed, Continuing... \n" "$(date)" >> /var/log/pythonDjangoSample.log
else
  printf "%s - ERROR Python not installed, try running this script again or continuing manually! Exiting... \n" "$(date)" >> /var/log/pythonDjangoSample.log
  exit 0
fi
}

function installDjango() {
# EPEL doesn't have the necessary version of Django to run the example project
# Use pip instead within a virtual environment.
pip install virtualenv
mkdir ~/ExampleApplication
cd ~/ExampleApplication || exit
virtualenv appenv
# install django package in the virtual environment
source appenv/bin/activate
pip install django # 6/1/2019 NOTE - Change the way this interacts. Pipe in the requirements.txt file from the sample project.
                   #                  Would need to change the order of function calls, or create a package for the project.

# Check that the django utility exists, don't advance unless we have it.
if [ "$(command -v django-admin)" ]; then
  printf "%s - Django installed, Continuing... \n" "$(date)" >> /var/log/pythonDjangoSample.log
else
  printf "%s - ERROR Django not installed, try running this script again, or continuing manually! Exiting... \n" "$(date)" >> /var/log/pythonDjangoSample.log
  exit 0
fi
}

function cloneRepo() {
  # First make sure we have git
  if [ "$(command -v git)" ]; then
    printf "%s - Git installed, Continuing... \n" "$(date)" >> /var/log/pythonDjangoSample.log
  else
    printf "%s - Git not installed... Installing now." "$(date)" >> /var/log/pythonDjangoSample.log
    yum install git
  fi

  cd /tmp || exit
  # Probably better to have a local repo/self hosted repo to clone from, but for the
  # sake of brevity clone from the example site...
  git clone https://github.com/microsoft/devops-project-samples/tree/master/python/django/webapp/Application
  mv python/django/webapp/Application ~/ExampleApplication
}

function startDjangoProject() {
  cd ~/ExampleApplication || exit
  source env/bin/activate
  cd Application || exit
  python manage.py runserver
}

# Possible use for only starting the server at boot in a cronjob or something?
if [ "$1" = "-startProject" ]
then
  startDjangoProject
fi

installPython
installDjango
cloneRepo
# At this point all necessary files/versions should be good.
# Just need to run the server...
startDjangoProject

exit 0
