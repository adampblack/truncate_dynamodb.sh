# this script assume
# Primary partition key	= reportid
# Primary sort key = timestamp
# please edit the line with jq to suit your table and key configuration

# variables - change to suit
TABLE_NAME=EXAMPLE_DYNAMO_DB_LOG_TABLE
AWS_PROFILE=EXAMPLE_PROFILE
AWS_REGION=ap-southeast-1
CSV_OUTPUT_PATH=/tmp/tmp_truncate_dynamodb.csv

# output the primary partition key and primary sort key into a csv
aws --profile $AWS_PROFILE \ 
    --region $AWS_REGION \
    dynamodb scan \
    --table-name $TABLE_NAME \
    | jq -j '.Items[] | (.reportid.N, ",", .timestamp.S, "\n")' > $CSV_OUTPUT_PATH

# read the primary partition key and primary sort key from the csv
# then delete each of the dynamodb items
{
  IFS=,
  while read -r reportid timestamp; do
    aws --profile $AWS_PROFILE \
        --region $AWS_REGION \
        dynamodb delete-item \
        --table-name $TABLE_NAME \
        --key '{ "reportid": {"N": "'$reportid'"}, "timestamp": {"S": "'$timestamp'"}}'
  done
} <$CSV_OUTPUT_PATH

# remove the temporary file used to store the primary partition key and primary sort key
rm $CSV_OUTPUT_PATH

    
