#!/bin/bash

##############################################################################
#
# This script will return 0 if the underlying application process is
# started.  This is primarily intended for use in environments that
# provide an application startup probe, in particular the Kubernetes
# `startupProbe` and `readinessProbe` hooks. See
# https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
# for more information.
#
##############################################################################

. /probe-common.sh

# The Bamboo uses a wrapper process to start the agent, and restart it
# on failure. The wrapper generates status files for itself and the
# underlying application, so we can use this for the basic status. See
# https://wrapper.tanukisoftware.com/doc/english/prop-statusfile.html,
# https://wrapper.tanukisoftware.com/doc/english/prop-java-statusfile.html
# and `bamboo-agent.sh` for details.
#
# If the Java process crashes it will be restarted by the wrapper; in
# that case the Java status will change and the readiness will be
# paused.

grep -q STARTED ${WRAPPER_STATUSFILE} \
     && grep -q STARTED ${JAVA_STATUSFILE}
