#!/bin/bash

# Define variables
PROJECT="WebAPI"
AUTHOR="Dev Team"

# Use Cat with a Here Document to print a multiline string
cat <<EOF
#####################################
# Project: $PROJECT
# Created by: $AUTHOR
# Description: This is a
# multiline string example.
#####################################
EOF

# Alternative: Write the multiline string to a file
cat <<EOF > config.txt
[Settings]
Name=$PROJECT
Status=Active
EOF
