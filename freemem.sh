#!/bin/bash

free -h | awk 'NR==2 {print "Total: "$2", Used: "$3", Free: "$4}';
