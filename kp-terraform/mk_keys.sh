#!/bin/bash

# Script to create ec2 keys, describe and import
#
KEYPAIRNAME=tf-infra-provision
KEYPEMOUT=$KEYPAIRNAME
#KEYPEMOUT2=${KEYPAIRNAME2}.pem

rm -f $HOME/.aws/$KEYPEMOUT 
# gen public key 
ssh-keygen -t rsa -C "$KEYPAIRNAME" -f ~/.ssh/$KEYPAIRNAME 
aws ec2 import-key-pair --key-name "$KEYPAIRNAME" --public-key-material fileb://~/.ssh/${KEYPAIRNAME}.pub
#

aws ec2 create-key-pair --key-name $KEYPAIRNAME --query 'KeyMaterial' --output text > $HOME/.aws/$KEYPEMOUT
chmod 400 $HOME/.aws/$KEYPEMOUT 

aws ec2 describe-key-pairs --key-name $KEYPAIRNAME 

printf "When done, delete via aws ec2 delete-key-pair --key-name $KEYPAIRNAME   \n\n"
