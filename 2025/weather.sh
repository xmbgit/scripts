#!/bin/bash

# a simple script to get the weather from "wttr.in"
echo "Weather: $(curl -s wttr.in?format='%C+%t')"
 
