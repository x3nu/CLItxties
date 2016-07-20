#!/bin/sh

# CLItxties - quickly post something to http://txti.es
#
# Authors:
# https://github.com/x3nu
# https://github.com/parazyd
# https://github.com/0mp
#
# Link: https://github.com/x3nu/CLItexties
#
# Required: curl, lynx, nano

# Configuration.
EDITOR=nano

# Constants.
URL='http://txti.es'
TEMP_FILE=`date +%s-%N`"-cl_txti.md"

# Print messages to stderr easily.
errcho() {
    >&2 echo $@
}

# Check the status code of the desired url is 404 which means it's
# probably free.
#
# parameters:
# $1 - the custom url end
#
# return 0 if the url is free; 1 otherwise
clitxties_is_available() {
    local code=$(curl -I "$URL/$1" 2>/dev/null | head -n 1 | cut -d$' ' -f2)
    if [ "$code" = "404" ]; then
        return 0
    else
        return 1
    fi
}

# Parameters:
# $1 - the content
# $2 - the url
# $3 - the edit code
#
# Retun 0 on success; 1 otherwise.
clitxties_post() {
    local data_urlencode
    local data

    data_urlencode="content=$1"
    data="&custom_url=$2"
    data="$data&custom_edit_code=$3"
    data="$data&form_level=2&submit=Save%20and%20done"

    curl -s --data-urlencode "$data_urlencode" --data "$data" "$URL" \
        | lynx -nostatus -stdin -dump -nolist \
        | grep -q "already exists" && return 1 || return 0
}

# Generates a random string suitable for a random URL.
# Source: https://gist.github.com/earthgecko/3089509#gistcomment-1250540
clitxties_random_url() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}

# Print the usage and exit with an error.
clitxties_usage() {
    cat <<EOF
CLItexties - Post to txti.es from the commandline

Usage: CLItxties.sh [-h] (-i [-e editor | -f file] (-r | url) | (-f file | -s) (-r | url) edit_code)
  -e editor use a different editor instead of the default nano(1)
  -f file   get the content from a file
  -h        print this usage and exit
  -i        enter the content, the url and the edit code interactively
  -r        use a randomly generated url
  -s        take input from the stdin

If you used MyCoolPost as customized URL you'll find your post at
http://txti.es/MyCoolPost and the edit link would be http://txti.es/MyCoolPost/edit
EOF
    exit 1
}

clitxties_main() {
    local input_method=""
    local random_url_enable="no"

    local content=""
    local custom_url=""
    local custom_edit_code=""

    # Require at least one option.
    if [ "$#" -lt 1 ]; then
        clitxties_usage
    fi

    while [ "$1" != "" ]; do
        case "$1" in
            -e)
                # Change the default editor.
                if [ "$#" -lt 2 ]; then
                    clitxties_usage
                fi
                EDITOR="$2"
                shift 2
                ;;
            -f)
                input_method="file"
                if [ "$#" -lt 2 ]; then
                    clitxties_usage
                fi
                content=$(<$2)
                shift 2
                ;;
            -h)
                clitxties_usage
                ;;
            -i)
                # Enter the interactive mode.
                input_method="interactive"
                shift
                ;;
            -r)
                # Get a randomized url.
                random_url_enable="yes"
                shift
                ;;
            -s)
                input_method="stdin"
                content=$(cat <&0);
                shift
                ;;
            *)
                # No more recogizable options. Time for the operands.
                break
                ;;
        esac
    done

    # Get the input either interactivly or via arguments.
    case $input_method in
        file|stdin)
            if [ "$random_url_enable" = "yes" ]; then
                custom_url=$(clitxties_random_url)
            else
                custom_url="$1"
                shift
            fi
            if [ "$#" -lt 1 ]; then
                clitxties_usage
            fi
            custom_edit_code="$1"
            ;;
        interactive)
            touch "/tmp/$TEMP_FILE"
            $EDITOR "/tmp/$TEMP_FILE"
            content=$(</tmp/$TEMP_FILE)
            rm "/tmp/$TEMP_FILE"
            if [ "$random_url_enable" = "yes" ]; then
                custom_url=$(clitxties_random_url)
            else
                printf "%s" "Custom URL: "
                read custom_url
            fi
            printf "%s" "Custom edit code: "
            read custom_edit_code
            ;;
        *)
            clitxties_usage
            ;;
    esac

    # Post!
    while
        clitxties_post "$content" "$custom_url" "$custom_edit_code"
        if [ "$?" -eq 0 ]; then
            if [ "$input_method" = "interactive" ]; then
                echo "Your post is online at: http://txti.es/$custom_url"
                echo "Your edit code is: $custom_edit_code"
                echo "You can edit your post at: http://txti.es/$custom_url/edit"
                echo "Save this code, or write it down somewhere, as it can't be recovered"
            else
                echo "http://txti.es/$custom_url $custom_edit_code"
            fi
            break
        elif [ "$random_url_enable" = "yes" ]; then
            if [ "$input_method" = "interactive" ]; then
                echo "$0: This url (\"$custom_url\") is already in use, let me try another one"
            fi
            custom_url=$(clitxties_random_url)
        elif [ "$input_method" = "interactive" ]; then
            printf "%s" "This URL (\"$custom_url\") is already in use, please choose a new one: "
            read custom_url
        else
            errcho "$0: error: The chosen URL (\"$custom_url\") is already in use"
            exit 1
        fi
    do
        :
    done
}

clitxties_main $*
