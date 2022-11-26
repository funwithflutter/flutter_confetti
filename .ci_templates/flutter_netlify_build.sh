#!/bin/bash

# Setup flutter
FLUTTER=`which flutter`
if [ $? -eq 0 ]
then
  # Flutter is installed
  FLUTTER=`which flutter`
else
  # Get flutter
  git clone https://github.com/flutter/flutter.git
  FLUTTER=flutter/bin/flutter
#   export PATH="$PATH":"$FLUTTER"
fi

FLUTTER_CHANNEL=stable
FLUTTER_VERSION=v2.5.1
$FLUTTER channel $FLUTTER_CHANNEL
$FLUTTER version $FLUTTER_VERSION

# # Setup FVM
# FVM=`which fvm`
# if [ $? -eq 0 ]
# then
#   # FVM is installed
#   FVM=`which fvm`
# else
#   # Get FVC
#   echo "Getting fvm"
#   $FLUTTER pub global activate fvm
#   export PATH="$PATH":"$HOME/.pub-cache/bin"
#   FVM=`which fvm`
# fi

# echo "Installing FVM"

# $FVM install

# echo "Running pub get"

# $FVM flutter pub get

# cd example

# echo "Building Flutter web"

# $FVM flutter build web --web-renderer canvaskit

# cd ..

cd example

$FLUTTER build web --web-renderer canvaskit

cd ..

echo "OK"