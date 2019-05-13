#!/bin/bash

refresh_token=$(curl -s --user ${CONJUR_AUTHN_LOGIN}:${CONJUR_AUTHN_API_KEY} ${CONJUR_APPLIANCE_URL}/authn/${CONJUR_ACCOUNT}/login)
#echo "1: $refresh_token"
response=$(curl -s -X POST ${CONJUR_APPLIANCE_URL}/authn/${CONJUR_ACCOUNT}/host%2Fjit-azure-internal%2Fjit-azure-web/authenticate -d ${refresh_token})
#echo "2: $response"
export access_token=$(echo -n $response | base64 | tr -d '\r\n')
#echo "3: $access_token"

curl -s -H "Authorization: Token token=\"${access_token}\"" \
	${CONJUR_APPLIANCE_URL}/secrets/${CONJUR_ACCOUNT}/variable/azure%2Froles%2F$1
