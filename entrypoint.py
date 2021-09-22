#!/usr/bin/python3

import os
import sys
import xml.etree.ElementTree as ET

from entrypoint_helpers import env, gen_cfg, logging, set_perms, str2bool, exec_app

RUN_USER = env['run_user']
RUN_GROUP = env['run_group']
BAMBOO_AGENT_HOME = env['bamboo_agent_home']
BAMBOO_AGENT_INSTALL_DIR = env['bamboo_agent_install_dir']
BAMBOO_SERVER = env.get('bamboo_server')
DOCKER_SOCK = '/var/run/docker.sock'

if not BAMBOO_SERVER:
    logging.error('No value for "BAMBOO_SERVER" found in the environment. Shutting down.')
    sys.exit(1)

BAMBOO_SERVER = BAMBOO_SERVER.rstrip('/')
if not BAMBOO_SERVER.endswith('/agentServer'):
    BAMBOO_SERVER += '/agentServer'
    env['bamboo_server'] = BAMBOO_SERVER

gen_cfg('wrapper.conf.j2', f'{BAMBOO_AGENT_HOME}/conf/wrapper.conf',
        user=RUN_USER, group=RUN_GROUP, overwrite=False)

# Although Docker is not installed in this base image, there's no easy way for an image
# derived from this base to perform this particular step, which must be run at container
# start rather than at build time.
if os.path.exists(DOCKER_SOCK):
    set_perms(DOCKER_SOCK, 'root', 'root', 0o666)

JAVA_OPTS = f'-Dbamboo.home={BAMBOO_AGENT_HOME}'

AGENT_OPTS = f'{BAMBOO_SERVER}'
if env.get('security_token'):
    AGENT_OPTS += f' -t {env["security_token"]}'

exec_app(['java', JAVA_OPTS, '-jar', f'{BAMBOO_AGENT_INSTALL_DIR}/atlassian-bamboo-agent-installer.jar', AGENT_OPTS], BAMBOO_AGENT_HOME,
         name='Bamboo Agent', env_cleanup=True)
