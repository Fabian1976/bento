#!/bin/bash

current_date=`date +%Y%m%d`
#Virtualbox
cd centos
packer build -only=virtualbox-iso centos-7.6-x86_64.json
cd ../builds
aws s3 cp centos-7.6.virtualbox.${current_date}.box s3://cmc-packer-images/vagrant/ --profile prod

#AWS AMI
#Is eigenlijk ook een virtualbox ISO maar dan met wat extra stappen specifiek voor AWS
cd ../centos
packer build -only=virtualbox-iso centos-7.6-x86_64_aws.json
cd ../builds
tar -xf centos-7.6.ami.${current_date}.box
tar -cf centos-7.6.ami.${current_date}.ova box.ovf centos-7.6-x86_64-disk001.vmdk
rm -f Vagrantfile box.ovf centos-7.6-x86_64-disk001.vmdk metadata.json
aws s3 cp centos-7.6.ami.${current_date}.ova s3://cmc-packer-images/amazon-ami/ --profile prod

aws ec2 import-image --description "Centos 7.6 CIS hardened level 2 encrypted" --license-type BYOL --disk-containers "Description=CentOS 7.6 CIS hardened level 2 encrypted,Format=ova,UserBucket={S3Bucket=cmc-packer-images,S3Key=amazon-ami/centos-7.6.ami.${current_date}.ova}" --platform Linux --encrypted --profile prod

#taskid: import-ami-0e2b4fa320abfb2a5
#aws ec2 describe-import-image-tasks --import-task-ids import-ami-0e2b4fa320abfb2a5 --profile prod
