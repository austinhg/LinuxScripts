#!/bin/bash
# Log into the dang AWS region that you dang-ol' want.
# Why they don't support more than one at a time? I have no idea. But, what I do
# know is that this works! So, I'm going to use it.
#
# Changelog:
#       2019.09.25, AHG - Creation
#

# TODO: Think about making this a command line flag - since user credentials
# aren't entered at runtime there's no need to hide what a user needs in history
read -p "Which AWS region do you want to log-in to: " varName

# Awesome list of different AWS regions/AZ's that we can log into!
if [ "$varName" == "us-east-1" ] || [ "$varName" == "N. Virginia" ] || [ "$varName" == "North Virginia" ] || [ "$varName" == "east-1" ] || [ "$varName" == "east 1" ]
then
    echo "Logging into us-east-1 (N. Virginia)..."
    $(aws ecr get-login --region us-east-1 --no-include-email)

elif [ "$varName" = "us-east-2" ] || [ "$varName" == "Ohio" ] || [ "$varName" == "east-2" ] || [ "$varName" == "east 2" ]
then
    echo "Logging into us-east-2 (Ohio)..."
    $(aws ecr get-login --region us-east-2 --no-include-email)

elif [ "$varName" = "us-west-1" ] || [ "$varName" == "California" ] || [ "$varName" == "Cali" ] || [ "$varName" == "west-1" ] || [ "$varName" == "west 1" ]
then
    echo "Logging into us-west-1 (California)..."
    $(aws ecr get-login --region us-west-1 --no-include-email)

elif [ "$varName" = "us-west-2" ] || [ "$varName" == "Oregon" ] || [ "$varName" == "west-2" ] || [ "$varName" == "west 2" ]
then
    echo "Logging into us-west-2 (Oregon)..."
    $(aws ecr get-login --region us-west-2 --no-include-email)

else
    echo "Please enter one of the following:"
    echo "us-east-1 | N. Virginia"
    echo "us-east-2 | Ohio"
    echo "us-east-1 | California"
    echo "us-west-2 | Oregon"
fi
