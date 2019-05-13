#!/bin/bash

az login -u $client_id -p $client_secret > /dev/null 2>&1
az ad sp create-for-rbac --skip-assignment
#az logout
