#!/bin/bash

refresh_token=$(curl -s --user ${CONJUR_AUTHN_LOGIN}:${CONJUR_AUTHN_API_KEY} ${CONJUR_APPLIANCE_URL}/authn/${CONJUR_ACCOUNT}/login)
response=$(curl -s -X POST ${CONJUR_APPLIANCE_URL}/authn/${CONJUR_ACCOUNT}/host%2Fjit-azure-internal%2Fjit-azure-web/authenticate -d ${refresh_token})
export access_token=$(echo -n $response | base64 | tr -d '\r\n')

for row in \
		$(curl -s -H "Authorization: Token token=\"${access_token}\"" \
        ${CONJUR_APPLIANCE_URL}/resources/${CONJUR_ACCOUNT}/variable/?search=azure%2Fcreds \
        | jq -r -c '.[].id'); do

				row=${row#"demo:variable:"}
				varID="${row////%2F}"

				appID=${varID#"azure%2Fcreds%2F"}

        expire1=$(curl -s -k -H "Authorization: Token token=\"${access_token}\"" \
        ${CONJUR_APPLIANCE_URL}/secrets/${CONJUR_ACCOUNT}/variable/${varID} \
				| jq -r '.expire')
				t1=`date --date="$expire1" +%s`

				dt2=`date +%Y-%m-%d\ %H:%M:%S`
				t2=`date --date="$dt2" +%s`

				let "tDiff=$t2-$t1"
				if [[ $tDiff -gt 0 ]]; then
						echo "delete sp: $appID"
						az ad sp  delete --id $appID

						# TODO: delete policy
						#echo "delete var: $varID"
				fi

done
