#!/bin/bash

#Assignment 3 Part A: Print Patterns

#Arguments Validation
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <size> <type>"
    echo "Example: $0 5 t1"
    exit 1
fi

row=$1
type=$2

if [ "$2" == "t1" ]; then

    for((i=1; i<=$1; i++))
    do 
        for((j=1; j<=($1 - i); j++)) 
        do 
            echo -n " "
        done

        for((k=1; k<=i; k++))
        do
            echo -n "*"
        done  

        echo ""
    done

fi 

if [ "$2" == "t2" ]; then

    for((i=1; i<=$1; i++))
    do 
        for((j=1; j<=(i); j++)) 
        do 
            echo -n "*"
        done
        echo ""
    done

fi

if [ "$2" == "t3" ]; then

    for((i=1; i<=$1; i++))
    do 
        for((j=1; j<=($1 - i); j++)) 
        do 
            echo -n " "
        done

        for((k=1; k<=2*i - 1; k++))
        do
            echo -n "*"
        done  

        echo ""
    done

fi

if [ "$2" == "t4" ]; then

    for((i=1; i<=$1; i++))
    do 
        for((j=1; j<=($1 -i + 1 ); j++)) 
        do 
            echo -n "*"
        done

        echo ""
    done

fi

if [ "$2" == "t5" ]; then

    for((i=1; i<=$1; i++))
    do 
        for((j=1; j<=(i-1); j++)) 
        do 
            echo -n " "
        done

        for((k=1; k<=($1 - i + 1); k++))
        do
            echo -n "*"
        done  

        echo ""
    done

fi

if [ "$2" == "t6" ]; then

    for ((i=$1-1; i>=1; i--))
    do
        for ((j=1; j<=($1-i); j++))
        do
            printf " "
        done

        for ((k=1; k<=2*i-1; k++))
        do
            printf "*"
        done

        echo
    done

fi

if [ "$2" == "t7" ]; then

    for((i=1; i<=$1; i++))
    do 
        for((j=1; j<=($1 - i); j++)) 
        do 
            echo -n " "
        done

        for((k=1; k<=2*i - 1; k++))
        do
            echo -n "*"
        done  

        echo ""
    done

    for ((i=$1-1; i>=1; i--))
    do
        for ((j=1; j<=($1-i); j++))
        do
            printf " "
        done

        for ((k=1; k<=2*i-1; k++))
        do
            printf "*"
        done

        echo
    done

fi




echo 