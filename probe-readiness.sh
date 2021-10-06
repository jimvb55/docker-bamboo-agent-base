#!/bin/bash

##############################################################################
#
# This script will return 0 if the underlying application process is
# ready.  This is primarily intended for use in environments that
# provide an application readiness proge, in particular the Kubernetes
# `readinessProbe` hook. See https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
# for more information.
#
##############################################################################

AGENT_LOG="/var/atlassian/application-data/bamboo-agent/logs/atlassian-bamboo.log"
LOG_TARGET="Bamboo agent '${HOSTNAME}' ready to receive builds."

# grep will return 0 if a match is found, non-zero otherwise.
grep -q "${LOG_TARGET}" ${AGENT_LOG}
