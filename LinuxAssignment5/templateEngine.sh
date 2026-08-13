#!/bin/bash


# Assignment 5 Part A


template="$1"


content=$(cat "$template")


shift


for arg in "$@"
do
    key="${arg%%=*}"      # '=' se pehle
    value="${arg#*=}"     # '=' ke baad


    content=$(echo "$content" | sed "s/{{${key}}}/${value}/g")
done


echo "$content"
