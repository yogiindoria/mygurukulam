#!/bin/bash
usage() {
    echo "Usage: $0 -t <tag_name> | -l | -d <tag_name>"
    exit 1
}
git rev-parse --is-inside-work-tree > /dev/null 2>&1 || { echo "Not a git repo"; exit 1; }
[ $# -eq 0 ] && usage

while [ $# -gt 0 ]; do
    case "$1" in
        -t) git tag "$2" && echo "Tag '$2' created."; shift 2 ;;
        -l) git tag --list; shift ;;
        -d) git tag -d "$2"; shift 2 ;;
        *) usage ;;
    esac
done