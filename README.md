A Bamboo Agent is a service that can run job builds. Each agent has a defined set of capabilities and can run builds only for jobs whose requirements match the agent's capabilities.
To learn more about Bamboo, see: https://www.atlassian.com/software/bamboo

If you are looking for **Bamboo Server Docker Image** it can be found [here](https://hub.docker.com/r/atlassian/bamboo/).

# Overview

Based on: git clone --recursive https://bitbucket.org/atlassian-docker/docker-bamboo-agent-base.git

This Docker container repo makes it easy(ish) to get a Bamboo Remote Agent up and running. It is intended to be used as a base to build from, and as such
contains limited built-in capabilities:

* JDK 11, JDK 17 (from v9.4.0), JDK 21 (from v10.1.0)
* Git & Git LFS
* Maven 3
* Python 3

Using this image as a base, you can create a custom remote agent image with your
desired build tools installed. Note that Bamboo Agent Docker Image does not
include a Bamboo server.

# Quick Start (pulls image from atlassion)

For the `BAMBOO_AGENT_HOME` directory that is used to store the repository data (amongst other things) we recommend mounting a host directory as a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes), or via a named volume.

To get started you can use a data volume, or named volumes. In this example we'll use named volumes.

Run an Agent:

    $> docker volume create --name bambooAgentVolume
    $> docker run -e BAMBOO_SERVER=http://bamboo.mycompany.com/agentServer/ -v bambooAgentVolume:/var/atlassian/application-data/bamboo-agent --name="bambooAgent" --hostname="bambooAgent" -d atlassian/bamboo-agent-base

**Success**. The Bamboo remote agent is now available to be approved in your Bamboo administration.

**Use docker version >= 20.10.9.**

# Building Custom JDK Images

This repository provides support for building Bamboo agent images with different JDK versions using either Eclipse Temurin or Red Hat UBI base images.

# Available Ubuntu base versions
This image is based on [Eclipse Temurin](https://hub.docker.com/_/eclipse-temurin) and ships with Ubuntu 24.04 (Noble).
For users requiring the earlier Ubuntu Jammy (22.04) version, the `jdk11-jammy` and `jdk17-jammy` tags are available.

**Note:** The `-jammy` tags are not maintained and are provided solely for compatibility and migration purposes. 
It is strongly recommended to use the latest `jdk11`, `jdk17`, `jdk21` tags in production environments to ensure you receive the latest updates and security patches.

## Clone the Repository

```bash
git clone --recursive https://github.com/jimvb55/docker-bamboo-agent-base.git
cd docker-bamboo-agent-base
```

## Building with Eclipse Temurin Base Images

The `Dockerfile` supports various Eclipse Temurin OpenJDK versions. Use the `BASE_IMAGE` build argument to specify the desired version:

```bash
# For JDK 8
docker build --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=eclipse-temurin:8-noble .

# For JDK 11
docker build --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=eclipse-temurin:11-noble .

# For JDK 17
docker build --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=eclipse-temurin:17-noble .

# For JDK 21
docker build --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=eclipse-temurin:21-noble .
```

Alternative base distributions are also available:
- Ubuntu 22.04 (Jammy): Replace `noble` with `jammy`
- Debian 12 (Bookworm): Replace `noble` with `bookworm`

## Building with Red Hat UBI Base Images

The `Dockerfile.ubi` provides support for Red Hat Universal Base Image (UBI) with OpenJDK. Use the `-f` flag to specify this Dockerfile and the `BASE_IMAGE` argument to choose the JDK version:

```bash
# For JDK 8
docker build -f Dockerfile.ubi --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=registry.access.redhat.com/ubi9/openjdk-8 .

# For JDK 11
docker build -f Dockerfile.ubi --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=registry.access.redhat.com/ubi9/openjdk-11 .

# For JDK 17
docker build -f Dockerfile.ubi --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=registry.access.redhat.com/ubi9/openjdk-17 .

# For JDK 21
docker build -f Dockerfile.ubi --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=registry.access.redhat.com/ubi9/openjdk-21 .
```

UBI 8 based images are also available:
- Replace `ubi9` with `ubi8` in the image name to use UBI 8 based images

# Building Node.js/NPM Agent Images

The `Dockerfile.node` provides support for Node.js-based build environments with NPM and Yarn package managers. The image is based on the official Node.js Docker images and includes:

- Node.js 20 LTS (or Node.js 18 LTS)
- NPM (latest version)
- Yarn package manager
- Build essentials for native module compilation
- Git & Git LFS
- Python 3

## Building with Node.js Base Images

```bash
# For Node.js 20 LTS (Debian Bookworm)
docker build -f Dockerfile.node --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=node:20-bookworm -t bamboo-agent-node .

# For Node.js 18 LTS (Debian Bookworm)
docker build -f Dockerfile.node --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=node:18-bookworm -t bamboo-agent-node .
```

Alternative base distributions are also available:
- Ubuntu 22.04 (Jammy): Replace `bookworm` with `jammy`

# Advanced Usage
For advanced usage, e.g. configuration, troubleshooting, supportability, etc.,
please check the [**Full Documentation**](https://atlassian.github.io/data-center-helm-charts/containers/BAMBOO-AGENT/).
