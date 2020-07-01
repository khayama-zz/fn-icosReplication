#!/bin/bash
ARGS=$@

TARGET_BUCKET=`echo "$ARGS" | jq -r '."TARGET_BUCKET"'`
TARGET_REGION=`echo "$ARGS" | jq -r '."TARGET_REGION"'`
TARGET_ENDPOINT="s3.private.$TARGET_REGION.cloud-object-storage.appdomain.cloud"
SOURCE_BUCKET=`echo "$ARGS" | jq -r '."bucket"'`
KEY=`echo "$ARGS" | jq -r '."key"'`

ACCESS_TOKEN=`curl -k -X POST \
--header "Content-Type: application/x-www-form-urlencoded" \
--header "Accept: application/json" \
--data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
--data-urlencode "apikey=$__OW_IAM_NAMESPACE_API_KEY" \
"$__OW_IAM_API_URL" \
| jq -r .access_token`

curl -v -i -X DELETE "https://$TARGET_BUCKET.$TARGET_ENDPOINT/$KEY" \
-H "Authorization: Bearer $ACCESS_TOKEN" > /tmp/result.txt

RESULT=$(cat /tmp/result.txt)

echo "{ \
\"args\": $ARGS, \
\"result\": $(RESULT="$RESULT" jq -n 'env.RESULT') \
}"

