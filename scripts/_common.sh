#!/bin/bash

# A bunch of functions to print colored messages.
ok() { printf '%s %s%s\n' "$(tput setaf 2)[√]" "$*" "$(tput sgr0)"; }
error() { printf '%s %s%s\n' "$(tput setaf 1)[x]" "$*" "$(tput sgr0)"; }
info() { printf '%s %s%s\n' "$(tput setaf 4)[i]" "$*" "$(tput sgr0)"; }
trace() { printf '%s %s%s\n' "$(tput setaf 8)[i]" "$*" "$(tput sgr0)"; }
warning() { printf '%s %s%s\n' "$(tput setaf 3)[!]" "$*" "$(tput sgr0)"; }

get_os_name() {
  unameOut="$(uname -s)"
  case "$unameOut" in
  Linux*) machine=Linux ;;
  Darwin*) machine=Mac ;;
  CYGWIN*) machine=Cygwin ;;
  MINGW*) machine=MinGw ;;
  MSYS_NT*) machine=Git ;;
  *) machine="UNKNOWN:${unameOut}" ;;
  esac
  echo "$machine"
}

# Define an array
# my_array=("apple" "banana" "cherry")
#
# Call the function with the value to search for and the array
#index=$(get_index "banana" "${my_array[@]}")
get_index() {
  local value=$1
  shift
  local array=("$@")

  echo "Searching for $value in ${array[*]}"

  for i in "${!array[@]}"; do
    if [[ "${array[$i]}" == "$value" ]]; then
      echo "$i"
    fi
  done

  echo "-1"
}

# Confirm a question with a default value
#
# Examples:
# > confirm && echo "Y" || echo "N"
# > confirm "Are you sure?" && echo "Yes" || echo "No"
confirm() {
  # call with a prompt string or use a default
  read -r -p "$(tput setaf 6)[?] ${*:-Are you sure?} [Y/n] $(tput sgr0)" response
  case "$response" in
  [nN][oO] | [nN])
    false
    ;;
  *)
    true
    ;;
  esac
}

#*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#*┃                             SET VARIABLES                                  ┃
#*┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

if [[ $(get_os_name) == "Mac" ]]; then
  gsed --version &>/dev/null || {
    error "gsed executable not found, make sure to install it using brew"
    exit 1
  }
  # I don't know why setting an alias doesn't work
  sed() {
    gsed "$@"
  }
fi
