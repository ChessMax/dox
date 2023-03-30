#!/usr/bin/env bash

echo 'Building started'
dart compile exe bin/dox.dart -o ./build/dox.exe
echo 'Build completed'