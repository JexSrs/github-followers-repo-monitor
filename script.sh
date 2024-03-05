#!/bin/bash

# Configuration
USERNAME=""
TOKEN=""
FOLLOWING_URL="https://api.github.com/users/$USERNAME/following"

# Function to get the list of users/orgs the specified user is following
get_following() {
    curl -s -H "Authorization: token $TOKEN" "$FOLLOWING_URL" | jq -r '.[] | .login'
}

# Function to list new public repos for a given user/org in the last 30 days
list_new_repos() {
    user=$1
    date_30_days_ago=$(date --date='30 days ago' +'%Y-%m-%dT%H:%M:%SZ')
    repos_url="https://api.github.com/users/$user/repos?type=owner&sort=created"
    curl -s -H "Authorization: token $TOKEN" "$repos_url" | jq --arg date_30_days_ago "$date_30_days_ago" -r '.[] | select(.created_at > $date_30_days_ago) | .html_url'
}

# Main
following_users=$(get_following)

for user in $following_users; do
    new_repos=$(list_new_repos $user)
    if [ ! -z "$new_repos" ]; then  # If new_repos is not empty
        echo "New repositories for $user in the last 30 days:"
        echo "$new_repos"
        echo "--------------------------------"
    fi
done
