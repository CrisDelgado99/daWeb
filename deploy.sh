#! /bin/bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=
export AWS_DEFAULT_REGION=us-east-1

#Variables con los datos que utilizaremos más adeñamte
STACK_NAME=tomcat
REGION=us-east-1
CLI_PROFILE=default
EC2_INSTANCE_TYPE=t2.micro

#Mensaje que le dice al usuario que se está desplegando el main.yml
echo -e "\n=========== Desplegando  main.yml ================="

aws cloudformation deploy \
	--region $REGION \
	--profile $CLI_PROFILE \
	--stack-name $STACK_NAME \
	--template-file main.yml \
	--no-fail-on-empty-changeset \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-override EC2InstanceType=$EC2_INSTANCE_TYPE