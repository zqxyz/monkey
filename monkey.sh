#!/bin/bash

# Function to checkout to the selected branch
checkout_branch() {
  local branch="${branches[$1]}"
  if [[ "$branch" == "remotes/"* ]]; then
    local local_branch=${branch#remotes/origin/}
    git checkout -b "$local_branch" --track "$branch"
  else
    git checkout "$branch"
  fi
}

# Fetch the latest branches
git fetch

# Get all branches and store them in an array
all_branches=($(git branch --all | sed 's/\*//g' | sed 's/ //g'))

# Initialize an empty array to store unique branches
branches=()

# Filter out remote branches if a local copy exists
for branch in "${all_branches[@]}"; do
  if [[ "$branch" == "remotes/"* ]]; then
    local_branch=${branch#remotes/origin/}
    if [[ ! " ${all_branches[@]} " =~ " ${local_branch} " ]]; then
      branches+=("$branch")
    fi
  else
    branches+=("$branch")
  fi
done

# Initialize an empty array to store matching branches
matches=()

# Search for branches that contain the search term
for i in "${!branches[@]}"; do
  if [[ "${branches[$i]}" == *"$1"* ]]; then
    matches+=("$i")
  fi
done

# If no matches found, exit
if [ ${#matches[@]} -eq 0 ]; then
  echo "No matching branches found."
  exit 1
fi

# If only one match found, checkout immediately
if [ ${#matches[@]} -eq 1 ]; then
  checkout_branch "${matches[0]}"
  exit 0
fi

# If multiple matches found, present options to the user
echo "Multiple branches found:"
for i in "${!matches[@]}"; do
  echo "$i) ${branches[${matches[$i]}]}"
done

# Read user input
if [ ${#matches[@]} -lt 10 ]; then
  read -n 1 choice
else
  read -r choice
fi

# Validate user input and checkout to the selected branch
if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -lt ${#matches[@]} ]; then
  checkout_branch "${matches[$choice]}"
else
  echo "Invalid choice."
  exit 1
fi
