from flask import Flask, jsonify,request
#from datetime import datetime
import time,datetime

import sys
import os
import json
app = Flask(__name__)

#post /jit/azure/get_sp
@app.route('/azure/get_sp' , methods=['POST'])
def create_azure_service_principal():
#    expire = datetime.datetime.now() + datetime.timedelta(minutes= ttl )

    request_data = request.get_json()
    role = request_data.get('role')

    # Get Role Details from Conjur
    ttl = os.popen('/app/get_role.sh '+role+' | jq -r .ttl').read()
    azure_role = os.popen('/app/get_role.sh '+role+' | jq -r .role').read()
    ttl = ttl.replace("\n","")
    azure_role = azure_role.replace("\n","")


    # Create Azure Service Principal
    azureCmd = os.popen('summon /app/create_sp.sh '+role).read()
    result_data = json.loads(azureCmd)

    result_data["role"] = role
    result_data["azure_role"] = azure_role
    result_data["ttl"] = ttl
    result_data["expire"] = (datetime.datetime.now() + datetime.timedelta(minutes=int(ttl))).strftime("%Y-%m-%d %H:%M:%S")

    # Add cred to Conjur
    min_result = json.dumps(result_data)
    min_result = min_result.replace("\r","")
    min_result = min_result.replace("\n","")

    ttl = os.popen('/app/add_creds.sh \''+min_result+'\'').read()

    return jsonify(result_data)


@app.route('/')
def hello_world():
    return '<html><head><title>Dynamic Secret for Conjur</title></head><body><h1>Dynamic Secret for Conjur</h1><br/>This is a demo of using CyberArk DAP/Conjur as the secret management platform for dynamic secrets'

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')
