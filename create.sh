#!/bin/bash

## Remove old files
script=ej_lambda.py
[ ! -f ${script}  ] && echo "Failed to locate file with function:  ${script}!" && return -1
[ -f ${script}.zip ] && rm -rf ${script}.zip

echo "******************************************"
echo "*** iam role ej_lambda  ******************"
echo "******************************************"
echo

echo -n " ## Create role: "
policy='{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
myarn=`aws iam create-role \
    --role-name ej_lambda \
    --assume-role-policy-document ${policy}` 2>/dev/null| perl -lne 'print if s/\|\|\s+(Arn)\s+\|(.*)\|\|/\2/' |tr -d ' '`
    
[ ! -z $myarn ] && ( myid=`echo $myarn|cut -d':' -f5`; echo " ...OK: [myid=${myid}; myarn=${myarn}]") || (echo '  ... FAILED Creating role!';return -1)

echo -n " ## Attach role, and wait 10sec: "
aws iam attach-role-policy \
    --role-name ej_lambda \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole && sleep 10
echo " ...OK"

echo -n " ## Create function from ${script},invoke it: "
zip ${script}.zip ${script}
aws lambda create-function \
    --function-name ej_lambda \
    --runtime python3.8 \
    --zip-file fileb://${script}.zip \
    --handler ej_lambda.ej_lambda \
    --role $myarn 
aws lambda invoke --function-name ej_lambda response.json
echo " ...OK"

echo -n "  ## Create cloudwatch rule: "
aws events put-rule \
    --name event5 \
    --schedule-expression 'cron(04 01 * * ? *)'
echo " ...OK"

echo -n "  ## Add permission "
aws lambda add-permission \
    --function-name ej_lambda \
    --statement-id event5 \
    --action 'lambda:InvokeFunction' \
    --principal events.amazonaws.com \
    --source-arn arn:aws:events:us-east-1:${myid}:rule/event5
echo " ...OK"    





# aws events put-targets --rule event5 --targets file://target.json
# ===================================================================
# First run
# #aws iam create-role --role-name ej_lambda --assume-role-policy-document file://trust-policy.json
# It will present you a ARN like this:
# "Arn": "arn:aws:iam::214639533279:role/CreateRole",
# Now run
# aws iam attach-role-policy --role-name ej_lambda --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
# zip ej_lambda.zip ej_lambda.py
# aws lambda create-function --function-name ej_lambda \
# --zip-file fileb://ej_lambda.zip --handler ej_lambda.ej_lambda --runtime python3.8 \
# --role arn:aws:iam::214639533279:role/ej_lambda

# aws events put-targets --rule event1 --targets file://target.json
# i changed line 9
