#!/bin/bash

#Assignment 3 Part B: Print Tomcat

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <num>"
    echo "Example: $0 5"
    exit 1
fi

num=$1

if (( num % 15 == 0 )); then
    echo "tomcat"

elif (( num % 3 == 0 )); then
    echo "tom"

elif (( num % 5 == 0 )); then
    echo "cat"

fi