# The name of the resulting executables.
packageName="SCP-Clicker"
# User-friendly package name.
friendlyPackageName="$packageName"
# Who made this? (Yes, change this to your name.)
author="Guard13007"
# Copyright year (ex 2014-2015 or 2015)
copyrightYear="2017"
# A unique identifier for your package.
# (It should be fine to leave this as its default.)
identifier="com.$author.$packageName"
# Current version (of your program)
source ./src/version.lua

###### Important! ONLY USE ABSOLUATE PATHS ######
# Where to place the resulting executables.
outputDir="$(pwd)/builds"
# Where the source code is. (This should be where your main.lua file is.)
sourceDir="$(pwd)/tmp/src"
# Files to include in ZIP packages. (ReadMe's, licenses, etc.)
includes="$(pwd)/build-includes"

# Where unzipped executables to make packages out of will be kept
# (This is also where LOVE executables will be kept before modifications to make your packages)
win32Dir="$outputDir/win32src"
osx10Dir="$outputDir/osx10src"

# Specify what version of love to use
loveVersion="0.10.2"

# Modified love executables (optional)
# (The default values are where the default exe's will be extracted)
win32exe="$win32Dir/love-$loveVersion-win32/love.exe"

# Mac icns files for package icon
# (It's best to just specify the same file for both?
# I don't think both are needed, but I am not very familiar with the Mac system.)
osxIconsDirectory="$osx10Dir/love.app/Contents/Resources"
osxFileIcon="GameIcon.icns"
osxBundleIcon="OS X AppIcon.icns"

# Remove old packages?
removeOld=true

# Allow overwrite? NOT IMPLEMENTED
# If this is false, LovePackaging will quit if you try to build with the same version number twice.
allowOverwrite=false
#NOTE to self: if autoNumberBuilds, this setting doesn't matter

# Auto-number builds?
# An "-buildN" will be added to the end of ZIP package names, with N being the Nth time this project was built.
#  (To do this, a build.number file is stored in $outputDir, so watch out for that.)
autoNumberBuilds=false

# Place latest builds in builds/latest?
#  (This is a copy, not a move.)
latestBuilds=false
latestBuildsDir="$outputDir/latest"

# Use curl or wget?
# (One of these lines should be commented out, the other not)
#download="curl -o"
download="wget --progress=bar:force -O"
