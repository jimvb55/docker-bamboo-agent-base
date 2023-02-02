#!/bin/bash -l
set -x

if [[ -n "${AGENT_EPHEMERAL_FOR_KEY}" ]]; then #AGENT_EPHEMERAL_FOR_KEY is set to a non-empty string
  export DISABLE_AGENT_AUTO_CAPABILITY_DETECTION="true"
fi


KUBE_NUM_EXTRA_CONTAINERS_OR_ZERO="${KUBE_NUM_EXTRA_CONTAINERS:=0}"
CONTAINERS_DIRECTORY=/pbc/kube

if [[ -d "$CONTAINERS_DIRECTORY" && $KUBE_NUM_EXTRA_CONTAINERS_OR_ZERO -ne 0 ]]; then
    retries=0
    # 30 retries per minute times 20 minutes = loop 600 times
    # it's so high because of docker downloads of side containers.
    CONTAINER_START_RETRY_COUNT=600
    echo "Waiting for $KUBE_NUM_EXTRA_CONTAINERS_OR_ZERO side containers to start"
    while true; do
        if [ $retries -eq $CONTAINER_START_RETRY_COUNT ]; then
            echo "Side containers failed to create file(s) in $CONTAINERS_DIRECTORY"
            ls -la $CONTAINERS_DIRECTORY
            break
        elif [ "$(find $CONTAINERS_DIRECTORY -type f| wc -l)" -ne "$KUBE_NUM_EXTRA_CONTAINERS_OR_ZERO" ]; then
            echo "No match, waiting some more"
            sleep 2
            let retries=retries+1
        else
            echo "all side containers have started"
            break
        fi
    done
fi

exec "$@"
