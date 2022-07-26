#!/bin/bash
if [[ -e old_user ]] ; then
  printf ‘the old user exists.\n’
  mv old_user new_user
fi
mv new_user user
