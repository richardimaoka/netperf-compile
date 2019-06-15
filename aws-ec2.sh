#!/bin/sh

######################################
# Parse the option and error handling
######################################
for OPT in "$@"
do
  case "$OPT" in
    '--aws-keypair' )
      if [ -z "$2" ]; then
          echo "option --aws-keypair requires an argument -- $1" 1>&2
          exit 1
      fi
      AWS_KEY_PAIR="$2"
      shift 2
      ;;
  esac
done

if [ -z "${AWS_KEY_PAIR}" ] ; then
  >&2 echo "ERROR: option --aws-keypair needs to be passed"
  exit 1
fi

#######################################
# Run EC2
#######################################

AMI_LINUX2=$(aws ec2 describe-images \
  --owners amazon \
  --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' \
  --query "reverse(sort_by(Images, &CreationDate))[0].ImageId" \
  --output text
)

aws ec2 run-instances \
  --image-id "${AMI_LINUX2}" \
  --instance-type "t2.micro" \
  --key-name "${AWS_KEY_PAIR}" \
  --network-interfaces \
    "AssociatePublicIpAddress=true,DeviceIndex=0" \
  --user-data file://user-data.txt

