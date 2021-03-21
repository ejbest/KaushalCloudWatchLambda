#!/bin/bash
set -x
rm -Rf foo
aws iam list-attached-role-policies --role-name ej_lambda > foo
set +x
mystr="`grep "arn:aws" foo`"
mymid=`echo $mystr | cut -d ":" -f 2-6 | cut -d " " -f 1`
myarn=`echo $mymid`
echo "mystr.....$mystr"
echo "mymid.....$mymid"
echo "myarn.....$myarn"
echo "aws iam detach-role-policy --role-name ej_lambda --policy-arn $myarn"
aws iam detach-role-policy --role-name ej_lambda --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name ej_lambda        
aws lambda delete-function --function-name ej_lambda 
