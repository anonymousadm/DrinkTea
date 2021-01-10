#! /bin/bash

_USER_NAME=$1
twurl set default ${_USER_NAME}

twurl /1.1/users/show.json?screen_name=${_USER_NAME} | jq .statuses_count

twurl /1.1/users/show.json?screen_name=${_USER_NAME} | jq .followers_count

twurl /1.1/users/show.json?screen_name=${_USER_NAME} | jq .friends_count

twurl /1.1/blocks/ids.json | jq .ids[] | wc -l

twurl /1.1/mutes/users/list.json | jq .users[].id_str | wc -l
