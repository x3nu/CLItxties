#!/bin/sh

# A test suite for CLItxties.sh.
#
# Author:
# https://github.com/0mp

# Configuration.
SCRIPT=./CLItxties.sh
EDIT_CODE="lovesexgod"
PROGRESS_PENDING_CHAR="\."

# Parameters:
# $1 - The character with which the progress bar is updated.
clitxties_update_progress_bar() {
    UPDATE="$1"
    PROGRESS="$(echo "$PROGRESS" | \
        sed 's/'"$PROGRESS_PENDING_CHAR"'/'"$UPDATE"'/')"
}

# Parameters:
# $1 - The test case.
# $2 - The character to update the progress bar with.
# $3 - The test message (typically something like PASS or FAIL).
# $4 - The exit code of the test case.
clitxties_result() {
    clitxties_update_progress_bar "$2"
    echo "[$1]"
    printf "%s (%d) $PROGRESS\n" "$3" "$4"
}

# Parameters:
# $1 - The test case.
# $2 - The exit code of the test case.
clitxties_success() {
    clitxties_result "$1" "#" "PASS" "$2"
}

# Parameters:
# $1 - The test case.
# $2 - The exit code of the test case.
clitxties_failure() {
    clitxties_result "$1" "F" "FAIL" "$2"
}

# Generates a random string suitable for a random URL.
# Source: https://gist.github.com/earthgecko/3089509#gistcomment-1250540
clitxties_random_url() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 | \
        head -n 1
}

# Parameters:
# $1 - The test case.
clitxties_test() {
    local exit_code
	eval $1
    exit_code="$?"
    echo ------------------------------------------------------
    if [ $exit_code -eq 0 ]; then
        clitxties_success "$1" "$exit_code"
    else
        clitxties_failure "$1" "$exit_code"
    fi
    echo ======================================================
}

# Parameters:
# $1 - The array of test case.
clitxties_run_tests() {
    echo ======================================================
    for testcase in "${testcases[@]}"; do
        echo "[$testcases]"
        echo ------------------------------------------------------
        clitxties_test "$testcase"
    done
}

# Test cases.
testcases=(\
    "$SCRIPT -f LICENSE $(clitxties_random_url) $EDIT_CODE" \
    "! $SCRIPT -h" \
    "! $SCRIPT -e vim -r" \
    "echo LICENSE | $SCRIPT -r -s $EDIT_CODE" \
    "! echo LICENSE | $SCRIPT -r -s" \
    # TODO Automate this case.
    "$SCRIPT -r -i -e vi"\
    )

# Progress bar setup.
PROGRESS=$(printf "[%${#testcases[@]}s]" " " | \
    sed 's/\ /'"$PROGRESS_PENDING_CHAR"'/g')

clitxties_run_tests
