#!/bin/bash

refresh_token=$(curl -s --user ${CONJUR_AUTHN_LOGIN}:${CONJUR_AUTHN_API_KEY} ${CONJUR_APPLIANCE_URL}/authn/${CONJUR_ACCOUNT}/login)
response=$(curl -s -X POST ${CONJUR_APPLIANCE_URL}/authn/${CONJUR_ACCOUNT}/host%2Fjit-azure-internal%2Fjit-azure-web/authenticate -d ${refresh_token})
export access_token=$(echo -n $response | base64 | tr -d '\r\n')

export _appID="$(echo $1 | jq -r .appId )"
export _value="$1"

echo "appID: $_appID"

_policy=$(cat <<END
- !policy
  id: creds
  body:
  - !variable
    id: $_appID
  - !permit
    role: !group /jit-azure-secrets/jit-admins
    privileges: [ read, execute ]
    resource: !variable $_appID
END
)

# Update Poicy
curl -s -H "Authorization: Token token=\"${access_token}\"" \
	${CONJUR_APPLIANCE_URL}/policies/${CONJUR_ACCOUNT}/policy/azure \
  -X POST -d "${_policy}"

# Add Creds
#curl -s -k -H "Authorization: Token token=\"${access_token}\"" \
#  -X POST -d '$1' \
#	${CONJUR_APPLIANCE_URL}/secrets/${CONJUR_ACCOUNT}/variable/azure%2Fcreds%2F${_appID}
