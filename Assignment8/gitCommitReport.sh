#!/bin/bash
usage() { echo "Usage: $0 -u <repo_url> -d <days> [-f csv|html] [-o output_file]"; exit 1; }

FORMAT="csv"; OUT_FILE=""; REPO_URL=""; DAYS=""

while [ $# -gt 0 ]; do
    case "$1" in
        -u) REPO_URL="$2"; shift 2 ;;
        -d) DAYS="$2"; shift 2 ;;
        -f) FORMAT="$2"; shift 2 ;;
        -o) OUT_FILE="$2"; shift 2 ;;
        *) usage ;;
    esac
done

[ -z "$REPO_URL" ] || [ -z "$DAYS" ] && [ -z "$REPO_URL" ] && usage

REPO_NAME=$(basename "$REPO_URL" .git)
WORK_DIR=$(mktemp -d)
CLONE_DIR="$WORK_DIR/$REPO_NAME"

if [ -d "$REPO_URL/.git" ]; then
    CLONE_DIR="$REPO_URL"
else
    git clone --quiet "$REPO_URL" "$CLONE_DIR" || { echo "Clone failed"; exit 1; }
fi

[ -z "$OUT_FILE" ] && OUT_FILE="commit_report_${REPO_NAME}.${FORMAT}"
case "$OUT_FILE" in /*) ;; *) OUT_FILE="$(pwd)/$OUT_FILE" ;; esac

cd "$CLONE_DIR" || exit 1
JIRA_PATTERN='^JIRA-[0-9]+:'
COMMITS=$(git log --since="${DAYS} days ago" --pretty=format:"%H")

if [ "$FORMAT" == "csv" ]; then
    echo "CommitId,AuthorName,AuthorEmail,CommitMessage,ChangedFiles,IsValid" > "$OUT_FILE"
    for c in $COMMITS; do
        HASH=$(git show -s --format="%H" "$c")
        AUTHOR=$(git show -s --format="%an" "$c")
        EMAIL=$(git show -s --format="%ae" "$c")
        MSG=$(git show -s --format="%s" "$c")
        FILES=$(git show --pretty="" --name-only "$c" | paste -sd ';' -)
        echo "$MSG" | grep -qE "$JIRA_PATTERN" && VALID="Yes" || VALID="No"
        echo "\"$HASH\",\"$AUTHOR\",\"$EMAIL\",\"$MSG\",\"$FILES\",\"$VALID\"" >> "$OUT_FILE"
    done
else
    {
        echo "<html><body><table border=1>"
        echo "<tr><th>Commit</th><th>Author</th><th>Email</th><th>Message</th><th>Files</th><th>Valid</th></tr>"
        for c in $COMMITS; do
            HASH=$(git show -s --format="%H" "$c")
            AUTHOR=$(git show -s --format="%an" "$c")
            EMAIL=$(git show -s --format="%ae" "$c")
            MSG=$(git show -s --format="%s" "$c")
            FILES=$(git show --pretty="" --name-only "$c" | paste -sd '<br>' -)
            echo "$MSG" | grep -qE "$JIRA_PATTERN" && VALID="Yes" || VALID="No"
            echo "<tr><td>$HASH</td><td>$AUTHOR</td><td>$EMAIL</td><td>$MSG</td><td>$FILES</td><td>$VALID</td></tr>"
        done
        echo "</table></body></html>"
    } > "$OUT_FILE"
fi
echo "Report generated: $OUT_FILE"