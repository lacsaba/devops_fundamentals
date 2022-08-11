#!/usr/bin/env bash

declare -r data_path=$(pwd)/lab_1/data
declare -r users_db=$data_path/users.db
declare -r db_required_message="$users_db must be created in order to use this program."

create_users_db_if_not_exists() {
  if ! [[ -e $users_db ]]; then
    echo -n "The user db doesn't exits. Do you want to Create it? Y/n "
    read answer
    if [[ $answer = 'Y' ]]; then
      touch $users_db
      echo "$users_db created."
    else
      echo $db_required_message
      exit 1
    fi
  fi
}

is_latin() {
  if [[ -z $1 ]]; then
    echo "Can not be blank"
    exit 1
  elif ! [[ "$1" =~ ^[a-zA-Z]+$ ]]; then
    echo "Only latin characters are allowed."
    exit 1
  fi
  exit 0
}

add_user() {
  echo "Add a new user to the db"
  declare local username
  while [[ -z $username ]] || ! (is_latin $username); do
    echo -n "username: "
    read username
  done
  declare local role
  while [[ -z $role ]] || ! (is_latin $role); do
    echo -n "role: "
    read role
  done
  echo "$username, $role" >>$users_db
  echo "New user added."
}

backup() {
  echo "Creating backup of $users_db"
  declare local backup_file="$data_path/$(date +%m-%d-%Y-%H-%M)-users.db.backup"
  cp $users_db $backup_file
  echo "Created backup db with the name $backup_file"
}

restore() {
  declare local latest_backup=$(ls -1 $data_path/*.backup 2>/dev/null | tail -n1)
  if ! [[ -e $latest_backup ]]; then
    echo "No backup file found"
  else
    echo "Restoring db from backup $latest_backup."
    cp $latest_backup $users_db
    echo "Restored from backup."
  fi
}

find() {
  declare local username
  declare local found=0

  while [[ -z $username ]]; do
    echo -n "Type the username: "
    read username
  done

  while read -r line; do
    declare local username_from_db="$(echo $line | cut -d',' -f 1)"
    declare local role_from_db="$(echo $line | cut -d',' -f 2)"
    if [[ $username_from_db == $username ]]; then
      echo "Username: $username_from_db, Role: $role_from_db"
      found=1
    fi
  done <$users_db

  if [[ $found -eq 0 ]]; then
    echo "User not found."
  fi
}

list() {
  declare -i local line_number=1
  if [[ $1 == "--reverse" ]]; then
    cat --number $users_db | tac
  else
    while read -r line; do
      echo "$line_number. $line"
      ((line_number++))
    done <$users_db
  fi
}

main() {
  case $1 in
  add)
    create_users_db_if_not_exists
    add_user
    ;;
  backup)
    create_users_db_if_not_exists
    backup
    ;;
  restore)
    create_users_db_if_not_exists
    restore
    ;;
  find)
    create_users_db_if_not_exists
    find
    ;;
  list)
    create_users_db_if_not_exists
    list $2
    ;;
  help | *)
    echo "Usage: $0 {add|backup|find|list|help}"
    ;;

  esac
}
main $@
