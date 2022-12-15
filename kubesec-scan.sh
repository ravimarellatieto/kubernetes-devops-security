#!/bin/bash

#kubesec-scan.sh

# using kubesec V2 api

kubesec ()
{
    local FILE="${1:-}";
    [[ ! -e "${FILE}" ]] && {
        echo "kubesec: ${FILE}: No such file" >&2;
        return 1
    };
    curl --silent \
      --compressed \
      --connect-timeout 5 \
      -sSX POST \
      --data-binary=@"${FILE}" \
      https://v2.kubesec.io/scan
}
scan_result=kubesec "$k8s_deployment_service.yaml"
scan_result=kubesec $./k8s_deployment_service.yaml  | jq .[0].message -r
scan_score=kubesec $"k8s_deployment_service.yaml" | jq .[0].score 
# using kubesec docker image for scanning
# scan_result=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml)
# scan_message=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml | jq .[].message -r)
# scan_score=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml | jq .[].score)

	
    # Kubesec scan result processing
    # echo "Scan Score : $scan_score"

	if [[ "${scan_score}" -ge 5 ]]; then
	    echo "Score is $scan_score"
	    echo "Kubesec Scan $scan_message"
	else
	    echo "Score is $scan_score, which is less than or equal to 5."
	    echo "Scanning Kubernetes Resource has Failed"
	    exit 1;
	fi;