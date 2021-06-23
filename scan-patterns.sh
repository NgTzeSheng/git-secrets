# This script will be run each time 'git commit' is called.

FILE=~/.git-secrets/git-leaks-patterns.txt

# Check if file exists
function exists {
    if test -f "$FILE"; then return
    fi 
    false
}

# Check if file age is > 1 week old
function check_age {
    local NOW=$(date +%s)
    local MODIFIED=$(date +"%s" -r $FILE)
    let diff=$NOW-$MODIFIED
    if [ "$diff" -gt "604800" ]; then return
    fi
    false
}

function massage_patterns {
    awk -F"regex {1}= {1}'''" '{print $2}' raw-text.tmp > $FILE # extract regex patterns
    sed -i '/^$/d; s/...$//' $FILE                              # remove trailing '''
}

# Initialise/Update file from git-leaks
function pull_patterns_file {
    curl -s https://raw.githubusercontent.com/zricethezav/gitleaks/master/config/default.go -o raw-text.tmp
    massage_patterns
    rm -f raw-text.tmp
}

if exists; then 
    # If patterns file exists, check age and update if necessary
    check_age && pull_patterns_file
else
    # Else initialise file
    pull_patterns_file
fi
# Cat ~/.git-secrets/git-leaks-patterns.txt for git-secrets
cat $FILE