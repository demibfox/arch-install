#!/bin/bash
yay -S --noconfirm --needed pokego-bin

# Check if the line is already in .bashrc
if ! grep -q "pokego --no-title -r 1,3,6" ~/.bashrc; then
    echo "pokego --no-title -r 1,3,6" >> ~/.bashrc
fi