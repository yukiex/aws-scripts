#!/bin/bash

help() {
    cat <<HELP
 Usage: $0 [options...] <arg>

 Options
    -h              show this help
    -p              aws profile
    -r              aws region

HELP
    exit 0
}

while getopts "p:r:h" OPT; do
    case $OPT in
        p) OPT_AWS_PROFILE="$OPTARG" ;;
        r) OPT_AWS_REGION="$OPTARG" ;;
        h) help ;;
        *) exit ;;
    esac
done

shift $((OPTIND - 1))

AWS_PROFILE=default
AWS_REGION=ap-northeast-1

if [ -n "$OPT_AWS_PROFILE" ]; then
    AWS_PROFILE=$OPT_AWS_PROFILE
fi

if [ -n "$OPT_AWS_REGION" ]; then
    AWS_REGION=$OPT_AWS_REGION
fi

aws --profile $AWS_PROFILE --region $AWS_REGION ec2 describe-instances | jq -r \
    '.[][].Instances[] | [.InstanceId, .ImageId, [.Tags[] | select(.Key == "Name").Value][], .InstanceType] | @tsv'

# END
