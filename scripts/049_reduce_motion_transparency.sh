#!/bin/bash
echo "Reducing motion and transparency..."

# Differentiate without color
defaults write com.apple.Accessibility DifferentiateWithoutColor -int 1

# Reduce motion
defaults write com.apple.Accessibility ReduceMotionEnabled -int 1
defaults write com.apple.universalaccess reduceMotion -int 1

# Reduce transparency
defaults write com.apple.universalaccess reduceTransparency -int 1

echo "Motion and transparency reduced."
