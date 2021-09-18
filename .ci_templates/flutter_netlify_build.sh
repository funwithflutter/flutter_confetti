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
fi

# Setup FVM
FVM=`which fvm`
if [ $? -eq 0 ]
then
  # FVM is installed
  FVM=`which fvm`
else
  # Get FVC
  echo "Getting fvm"
  $FLUTTER pub global activate fvm
  export PATH="$PATH":"$HOME/.pub-cache/bin"
fi


fvm install

fvm flutter pub get

cd example

fvm flutter build web

echo "OK"