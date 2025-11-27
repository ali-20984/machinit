#!/bin/bash
echo "Disabling Spotlight indexing..."

# Disable indexing on all volumes
sudo mdutil -i off -a

echo "Spotlight indexing disabled."
