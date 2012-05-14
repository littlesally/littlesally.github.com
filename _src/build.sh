#!/bin/bash

xcodebuild -configuration Release
/bin/cp -r build/Release/PostToSally.app ../_app
