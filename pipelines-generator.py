from pathlib import Path
import os
import jinja2 as j2

TEMPLATE_FILE = 'bitbucket-pipelines.yml.j2'
images = {

    'Bamboo Agent': {
        21: {
            'mac_key': 'bamboo',
            'start_version': '10.1',
            'default_release': True,
            'base_image': 'eclipse-temurin:21-noble',
            'tag_suffixes': ['jdk21', 'ubuntu'],
            'dockerfile': 'Dockerfile',
            'docker_repos': ['atlassian/bamboo-agent-base'],
            'batches': 16
        },
        "21-ubi": {
            'mac_key': 'bamboo',
            'start_version': '10.1',
            'base_image': 'registry.access.redhat.com/ubi9/openjdk-21',
            'tag_suffixes': ['ubi9','ubi9-jdk21'],
            'dockerfile': 'Dockerfile.ubi',
            'docker_repos': ['atlassian/bamboo-agent-base'],
            'snyk_threshold': 'critical'
        },
        "17-default": {
            'mac_key': 'bamboo',
            'start_version': '9.4',
            'end_version': '10.1',
            'default_release': True,
            'base_image': 'eclipse-temurin:17-noble',
            'tag_suffixes': ['jdk17', 'ubuntu'],
            'dockerfile': 'Dockerfile',
            'docker_repos': ['atlassian/bamboo-agent-base'],
            'batches': 16
        },
        17: {
            'mac_key': 'bamboo',
            'start_version': '10.1',
            'base_image': 'eclipse-temurin:17-noble',
            'tag_suffixes': ['jdk17', 'ubuntu'],
            'dockerfile': 'Dockerfile',
            'docker_repos': ['atlassian/bamboo-agent-base'],
            'batches': 16
        },
        "17-ubi": {
            'mac_key': 'bamboo',
            'start_version': '9.4',
            'base_image': 'registry.access.redhat.com/ubi9/openjdk-17',
            'tag_suffixes': ['ubi9','ubi9-jdk17'],
            'dockerfile': 'Dockerfile.ubi',
            'docker_repos': ['atlassian/bamboo-agent-base'],
            'snyk_threshold': 'critical'
        },
        "11-default": {
            'mac_key': 'bamboo',
            'start_version': '9.3',
            'end_version': '9.4',
            'default_release': True,
            'base_image': 'eclipse-temurin:11-noble',
            'tag_suffixes': ['jdk11', 'ubuntu'],
            'dockerfile': 'Dockerfile',
            'docker_repos': ['atlassian/bamboo-agent-base'],
            'batches': 12
        },
        11: {
            'mac_key': 'bamboo',
            'start_version': '9.4',
            'end_version': '10',
            'base_image': 'eclipse-temurin:11-noble',
            'tag_suffixes': ['jdk11', 'ubuntu'],
            'dockerfile': 'Dockerfile',
            'docker_repos': ['atlassian/bamboo-agent-base'],
            'batches': 12
        }
    }
}


def main():
    jenv = j2.Environment(
        loader=j2.FileSystemLoader('.'),
        lstrip_blocks=True,
        trim_blocks=True)
    template = jenv.get_template(TEMPLATE_FILE)
    generated_output = template.render(images=images, batches=8)

    print(generated_output)

if __name__ == '__main__':
    main()
