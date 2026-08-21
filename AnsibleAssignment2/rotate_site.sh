#!/bin/bash
MEMBERS=(yogesh bhumika devashish jeet mayank prajwal)
COUNT=${#MEMBERS[@]}
BLOCK=$(( $(date +%s) / 120 ))
IDX=$(( BLOCK % COUNT ))
CURRENT=${MEMBERS[$IDX]}
ln -sfn /var/www/sites/$CURRENT /var/www/html/team1
systemctl reload nginx
