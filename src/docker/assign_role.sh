#!/bin/bash

az login -u $client_id -p $client_secret > /dev/null 2>&1
sleep 1s

az role assignment create --assignee $1 --role $2
#az logout
