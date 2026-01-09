#!/bin/bash

# counts the number of running processes on the system and outputs the number
echo -e "Running processes: \e[31m$(ps -e | wc -l)\e[0m"
