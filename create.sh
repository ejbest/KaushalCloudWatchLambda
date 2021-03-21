#!/bin/bash
set -x
rm -Rf ej_lambda.zip
rm -Rf foo
#create everything now 
echo "aws iam create-role --role-name ej_lambda --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' "
aws iam create-role --role-name ej_lambda --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' > foo
#aws iam create-role --role-name ej_lambda --assume-role-policy-document file://trust-policy.json > foo
set +x
mystr="`grep "arn:aws" foo`"
mymid=`echo $mystr | cut -d ":" -f 2-25`
myarn=`echo $mymid | tr -d '",'`
#myarn="${myarn}/service-role/ej_lambda"
echo "mystr.....$mystr"
echo "mymid.....$mymid"
echo "myarn.....$myarn"
arn="arn:aws:iam::362863965643:role/ej_lambda"
echo "******************************************"
echo "******************************************"
echo "******************************************"
echo "aws iam attach-role-policy --role-name ej_lambda --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
aws iam attach-role-policy --role-name ej_lambda --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
sleep 10
echo "******************************************"
echo "******************************************"
echo "******************************************"
zip ej_lambda.zip ej_lambda.py
echo "******************************************"
echo "******************************************"
echo "******************************************"
echo "aws lambda create-function --function-name ej_lambda --runtime python3.8 --zip-file fileb://ej_lambda.zip --handler ej_lambda.handler --role $arn" 
aws lambda create-function --function-name ej_lambda --runtime python3.8 --zip-file fileb://ej_lambda.zip --handler ej_lambda.ej_lambda --role $arn
aws lambda invoke --function-name ej_lambda response.json
echo "******************************************"
echo "******************************************"
echo "******************************************"
echo "******************************************"
# #create cloudwatch rule
aws events put-rule \
    --name event5 \
    --schedule-expression 'cron(04 01 * * ? *)'

aws lambda add-permission \
    --function-name ej_lambda \
    --statement-id event5 \
    --action 'lambda:InvokeFunction' \
    --principal events.amazonaws.com \
    --source-arn arn:aws:events:us-east-1:362863965643:rule/event5

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

# aws events put-rule \
# --name my-weekly-event \
# --schedule-expression 'cron(0 9 * * ? *)'

# aws lambda add-permission \
# --function-name ej_lambda \
# --statement-id my-weekly-event \
# --action 'lambda:InvokeFunction' \
# --principal events.amazonaws.com \
# --source-arn arn:aws:events:us-west-2:214639533279:rule/my-weekly-event

# aws events put-targets --rule event1 --targets file://target.json
# i changed line 9
