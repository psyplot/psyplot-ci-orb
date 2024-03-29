#!/bin/bash

# configure the git user
#
# This command has been taken from the official orb-tools-orb at
# https://github.com/CircleCI-Public/orb-tools-orb/releases/tag/v10.0.5

if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    # No user name or email set, default to CIRCLE_USERNAME-based identifiers
    git config --global user.name "$CIRCLE_USERNAME"
    git config --global user.email "$CIRCLE_USERNAME@users.noreply.github.com"
else
    git config --global user.name "${GIT_USER_NAME}"
    git config --global user.email "${GIT_EMAIL}"
fi
