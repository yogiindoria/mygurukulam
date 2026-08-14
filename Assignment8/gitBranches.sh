#!/bin/bash
usage() {
    echo "Usage:"
    echo "  $0 -l"
    echo "  $0 -b <branch_name>"
    echo "  $0 -d <branch_name>"
    echo "  $0 -m -1 <branch1> -2 <branch2>"
    echo "  $0 -r -1 <branch1> -2 <branch2>"
    exit 1
}

git rev-parse --is-inside-work-tree > /dev/null 2>&1 || { echo "Not a git repo"; exit 1; }

ACTION=""; BRANCH1=""; BRANCH2=""; SINGLE_BRANCH=""
[ $# -eq 0 ] && usage

while [ $# -gt 0 ]; do
    case "$1" in
        -l) ACTION="list"; shift ;;
        -b) ACTION="create"; SINGLE_BRANCH="$2"; shift 2 ;;
        -d) ACTION="delete"; SINGLE_BRANCH="$2"; shift 2 ;;
        -m) ACTION="merge"; shift ;;
        -r) ACTION="rebase"; shift ;;
        -1) BRANCH1="$2"; shift 2 ;;
        -2) BRANCH2="$2"; shift 2 ;;
        *) usage ;;
    esac
done

case "$ACTION" in
    list) git branch --format='%(refname:short)' ;;
    create) git branch "$SINGLE_BRANCH" && echo "Branch '$SINGLE_BRANCH' created." ;;
    delete) git branch -D "$SINGLE_BRANCH" ;;
    merge)
        git checkout "$BRANCH2" && git merge "$BRANCH1" --no-edit
        ;;
    rebase)
        git checkout "$BRANCH1" && git rebase "$BRANCH2"
        ;;
    *) usage ;;
esac