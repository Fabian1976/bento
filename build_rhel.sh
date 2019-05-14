current_date=`date +%Y%m%d`
#Virtualbox
cd rhel
packer build -only=virtualbox-iso rhel-7.6-x86_64.json
cd ../builds
aws s3 cp rhel-7.6.virtualbox.${current_date}.box s3://cmc-packer-images/vagrant/ --profile prod

#AWS AMI
#Is eigenlijk ook een virtualbox ISO maar dan met wat extra stappen specifiek voor AWS
cd ../rhel
packer build -only=virtualbox-iso rhel-7.6-x86_64_aws.json
cd ../builds
tar -xf rhel-7.6.ami.${current_date}.box
tar -cf rhel-7.6.ami.${current_date}.ova box.ovf rhel-7.6-x86_64-disk001.vmdk
rm -f Vagrantfile box.ovf rhel-7.6-x86_64-disk001.vmdk metadata.json
aws s3 cp rhel-7.6.ami.${current_date}.ova s3://cmc-packer-images/amazon-ami/ --profile prod

aws ec2 import-image --description "Redhat 7.6 CIS hardened level 2 encrypted" --license-type BYOL --disk-containers "Description=Redhat 7.6 CIS hardened level 2 encrypted,Format=ova,UserBucket={S3Bucket=cmc-packer-images,S3Key=amazon-ami/rhel-7.6.ami.${current_date}.ova}" --platform Linux --encrypted --profile prod

#taskid: import-ami-048f3281d63035df1
#aws ec2 describe-import-image-tasks --import-task-ids import-ami-048f3281d63035df1 --profile prod
