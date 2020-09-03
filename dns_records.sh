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

ZONE_IDS=($(aws --profile $AWS_PROFILE --region $AWS_REGION route53 list-hosted-zones --output json | jq -r ".HostedZones[] | .Id "))

for ZONE_ID in "${ZONE_IDS[@]}"; do
    aws --profile $AWS_PROFILE --region $AWS_REGION route53 list-resource-record-sets --hosted-zone-id $ZONE_ID --output json | jq '.ResourceRecordSets [] | if has("ResourceRecords") then [.Name, .Type, .TTL, ([.ResourceRecords[] .Value] | join(","))] else [.Name, .Type, -1, (.AliasTarget .DNSName)] end | @tsv' -r
done

# END
