#!/bin/bash

TARGETS=("exploitme" "exploitme-safestack" "exploitme-safestack-cfi" "exploitme-safestack-cfi-aslr")

echo "" > test.log

for target in "${TARGETS[@]}"; do
    ./exploit.py --target $target >> test.log
    if [ -e "$target.exploited" ]; then
        echo "$target: OK"
    else
        echo "$target: Not OK"
    fi
done

rm *.exploited
