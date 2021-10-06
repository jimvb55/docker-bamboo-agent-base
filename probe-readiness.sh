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

. /probe-common.sh

# This is expected to be used in conjunction with the startup
# probe. Unlike `probe-startup.sh` we don't check for the startup log
# message, as this may disappear due to log rotation. However if the
# Java process crashes it will be restarted by the wrapper; in that
# case the Java status will change and the readiness will be paused.
grep -q STARTED ${WRAPPER_STATUSFILE} \
     && grep -q STARTED ${JAVA_STATUSFILE}
