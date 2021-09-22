import pytest

from helpers import get_app_home, get_app_install_dir, get_bootstrap_proc, get_procs, \
    parse_properties, parse_xml, run_image, wait_for_http_response, wait_for_proc



BOOTSTRAP_PROC = 'com.atlassian.bamboo.agent.bootstrap.AgentBootstrap'


def test_wrapper_conf(docker_cli, image, run_user):
    environment = {
        'BAMBOO_SERVER': 'http://localhost',
        'WRAPPER_JAVA_INITMEMORY': '383',
        'WRAPPER_JAVA_MAXMEMORY': '576',
        'IGNORE_SERVER_CERT_NAME': 'true',
        'ALLOW_EMPTY_ARTIFACTS': 'true',
    }
    container = run_image(docker_cli, image, user=run_user, environment=environment)
    _jvm = wait_for_proc(container, BOOTSTRAP_PROC)

    procs_list = get_procs(container)
    jvm = [proc for proc in procs_list if BOOTSTRAP_PROC in proc][0]
    
    assert environment["BAMBOO_SERVER"] in jvm
    assert f'-Xms{environment["WRAPPER_JAVA_INITMEMORY"]}m' in jvm
    assert f'-Xmx{environment["WRAPPER_JAVA_MAXMEMORY"]}m' in jvm
    assert f'-Dbamboo.agent.ignoreServerCertName={environment["IGNORE_SERVER_CERT_NAME"]}' in jvm
    assert f'-Dbamboo.allow.empty.artifacts={environment["ALLOW_EMPTY_ARTIFACTS"]}' in jvm
