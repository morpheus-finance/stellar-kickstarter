#!/bin/bash

set -o noclobber

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT="$SCRIPT_DIR/.."
source "$SCRIPT_DIR/_common.sh"

SHOULD_SET_SERVICE_ROLE_KEY=false
FLAVOR=""
INTERACTIVE=true
__ALLOWED_FLAVORS__=(local_test local dev prod)

print_help() {
  local __HELP__
  __HELP__="Set the env to run the app.

Usage: set-env [flags]

Flags:
  $(tput bold)-f, --flavor <flavor>$(tput sgr0)
\tThe app flavor to use for tests. Available flavors are: ${__ALLOWED_FLAVORS__[*]}
  $(tput bold)--set-service-role-key$(tput sgr0)
\tWhether to se the SERVICE_ROLE_KEY in the env.
  $(tput bold)--no-interactive$(tput sgr0)
\tSkip all prompts and run the script non-interactively.
  $(tput bold)-h, --help$(tput sgr0)
\tPrint this usage information."
  echo -e "$__HELP__" | expand -t 6
}

# Parses the command line arguments and returns the options in a format that can
# be used by the rest of the script.
#
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$("$SCRIPT_DIR/getopt" -o "hf:" -l "flavor:,set-service-role-key,no-interactive,help" -a -- "$@")

# Set the positional parameters to those parsed by getopt.
eval set -- "$options"

# Loop through the options and set the variables accordingly.
while true; do
  case "$1" in
  -h | --help)
    # Show help and exit.
    print_help
    exit 0
    ;;

  -f | --flavor)
    FLAVOR="$2"
    shift 2
    ;;

  --set-service-role-key)
    SHOULD_SET_SERVICE_ROLE_KEY=true
    shift
    ;;

  --no-interactive)
    INTERACTIVE=false
    shift
    ;;

  --)
    shift
    break
    ;;

  ?)
    error "Unknown option $1"
    print_help
    exit 1
    ;;
  esac
done

# Error if flavor is not set
if [ -z "$FLAVOR" ]; then
  error "Flavor is required. Use -f, --flavor <flavor> to set the flavor. Supported flavors are: ${__ALLOWED_FLAVORS__[*]}"
  exit 1
fi

# shellcheck disable=SC2076
if [[ ! " ${__ALLOWED_FLAVORS__[*]} " =~ " ${FLAVOR} " ]]; then
  error "Invalid flavor $FLAVOR. Supported flavors are: ${__ALLOWED_FLAVORS__[*]}"
  exit 1
fi

if $INTERACTIVE; then
  warning "Setting up the $FLAVOR env. This will overwrite the env at app/.env.$FLAVOR"
  read -p "Are you sure? Press ENTER to continue or Ctrl+C to cancel"
fi

# Start the Supabase local instance
supabase start 2>/dev/null

ok "Supabase local instance is up and running"

# Populate env file
json=$(supabase status -o json 2>/dev/null)
SUPABASE_URL=$(echo "$json" | jq -r ".API_URL")
SUPABASE_SERVICE_ROLE_KEY=$(echo "$json" | jq -r ".SERVICE_ROLE_KEY")
SUPABASE_ANON_KEY=$(echo "$json" | jq -r ".ANON_KEY")

info "Setting up the env file for the app..."

# ">|" is used to overwrite the file if it exists
echo "SUPABASE_URL=$SUPABASE_URL" >|"$PROJECT_ROOT/app/.env.$FLAVOR"
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >>"$PROJECT_ROOT/app/.env.$FLAVOR"

if $SHOULD_SET_SERVICE_ROLE_KEY; then
  echo "SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY" >>"$PROJECT_ROOT/app/.env.$FLAVOR"
fi

ok "Env file set up successfully as app/.env.$FLAVOR"
