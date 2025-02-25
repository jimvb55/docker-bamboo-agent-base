<div align="center">

# 🎋 Bamboo Agent Base

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://hub.docker.com/r/atlassian/bamboo-agent-base)
[![Bamboo](https://img.shields.io/badge/Bamboo-10.2.1-0052CC?style=flat&logo=bamboo&logoColor=white)](https://www.atlassian.com/software/bamboo)

*A flexible and powerful Docker-based build agent for Atlassian Bamboo*

</div>

---

A Bamboo Agent is a service that can run job builds. Each agent has a defined set of capabilities and can run builds only for jobs whose requirements match the agent's capabilities.
To learn more about Bamboo, see: https://www.atlassian.com/software/bamboo

> 🔍 Looking for the **Bamboo Server Docker Image**? Find it [here](https://hub.docker.com/r/atlassian/bamboo/).

# 📋 Overview

Based on repo: `git clone --recursive https://bitbucket.org/atlassian-docker/docker-bamboo-agent-base.git`

> ⚠️ Note: Bamboo Agent Docker Image does not include a Bamboo server.

# 🚀 Quick Start

This Docker container repo makes it easy to get a Bamboo Remote Agent up and running. It is intended to be used as a base to build from, and comes with the following capabilities:

| Category | Tools & Versions |
|----------|-----------------|
| ☕ Java | JDK 11, JDK 17 (v9.4.0+), JDK 21 (v10.1.0+) |
| 🔧 Build Tools | Maven 3 |
| 📦 Version Control | Git & Git LFS |
| 🐍 Scripting | Python 3 |

Using this image as a base, you can create a custom remote agent image with your desired build tools installed.

**Pulls image direct from Atlassian JDK21 - no build required**

For the `BAMBOO_AGENT_HOME` directory that is used to store the repository data, we recommend mounting a host directory as a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes), or via a named volume.

<details>
<summary>📝 Run an Agent with Named Volume</summary>

```bash
# Create a volume for agent data
docker volume create --name bambooAgentVolume

# Run the agent
docker run -e BAMBOO_SERVER=http://bamboo.mycompany.com/agentServer/ \
          -v bambooAgentVolume:/var/atlassian/application-data/bamboo-agent \
          --name="bambooAgent" \
          --hostname="bambooAgent" \
          -d atlassian/bamboo-agent-base
```

</details>

> ✅ **Success**: The Bamboo remote agent is now available to be approved in your Bamboo administration.

**Requirements**: Docker version >= 20.10.9

# 🛠️ Building Custom Agent Images

This repository provides support for building specialized Bamboo agent images. Choose your preferred stack:

## 🔨 Getting Started

```bash
git clone --recursive https://github.com/jimvb55/docker-bamboo-agent-base.git
cd docker-bamboo-agent-base
```

## ☕ Java/Maven Agent Images

### Features
| Category | Tools & Versions |
|----------|-----------------|
| ☕ Java | JDK 11, JDK 17 (v9.4.0+), JDK 21 (v10.1.0+) |
| 🔧 Build Tools | Maven 3 |
| 📦 Version Control | Git & Git LFS |
| 🐍 Scripting | Python 3 |

### Base Image Options

<details>
<summary>🏗️ Eclipse Temurin Base Images</summary>

The `Dockerfile` supports various Eclipse Temurin OpenJDK versions:

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

**Available Distributions**:
- 🌟 Ubuntu 24.04 (Noble) - Default
- 🔄 Ubuntu 22.04 (Jammy) - Replace `noble` with `jammy`
- 📦 Debian 12 (Bookworm) - Replace `noble` with `bookworm`

</details>

<details>
<summary>🏢 Red Hat UBI Base Images</summary>

The `Dockerfile.ubi` provides support for Red Hat Universal Base Image (UBI) with OpenJDK:

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

**Available UBI Versions**:
- 🌟 UBI 9 (Default)
- 🔄 UBI 8 - Replace `ubi9` with `ubi8` in the image name

</details>

## 📦 Node.js/NPM Agent Images

The `Dockerfile.node` provides a modern Node.js development environment:

### Features

| Category | Components |
|----------|------------|
| 🟩 Runtime | Node.js 20/18 LTS |
| 📦 Package Managers | NPM (latest), Yarn |
| 🛠️ Build Tools | build-essential |
| 🔧 Version Control | Git & Git LFS |
| 🐍 Scripting | Python 3 |

### Building Node.js Images

<details>
<summary>🏗️ Available Node.js Versions</summary>

```bash
# For Node.js 20 LTS (Debian Bookworm)
docker build -f Dockerfile.node --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=node:20-bookworm -t bamboo-agent-node .

# For Node.js 18 LTS (Debian Bookworm)
docker build -f Dockerfile.node --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=node:18-bookworm -t bamboo-agent-node .
```

**Available Distributions**:
- 📦 Debian 12 (Bookworm) - Default
- 🔄 Ubuntu 22.04 (Jammy) - Replace `bookworm` with `jammy`

</details>

## 🔷 .NET Agent Images

The `Dockerfile.dotnet` provides a comprehensive .NET development environment:

### Features

| Category | Components |
|----------|------------|
| 🔷 Runtime | .NET SDK 8.0/6.0 LTS |
| 🐙 Deployment | Octopus Deploy CLI |
| 🛠️ Build Tools | build-essential |
| 🔧 Version Control | Git & Git LFS |
| 🐍 Scripting | Python 3 |

### Building .NET Images

<details>
<summary>🏗️ Available .NET SDK Versions</summary>

```bash
# For .NET 8.0 LTS (Debian Bookworm)
docker build -f Dockerfile.dotnet --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim -t bamboo-agent-dotnet .

# For .NET 6.0 LTS (Debian Bookworm)
docker build -f Dockerfile.dotnet --build-arg BAMBOO_VERSION=10.2.1 --build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/sdk:6.0-bookworm-slim -t bamboo-agent-dotnet .
```

**Available Distributions**:
- 📦 Debian 12 (Bookworm) - Default
- 🔄 Ubuntu 22.04 (Jammy) - Replace `bookworm` with `jammy`

</details>

# 📚 Advanced Usage

For advanced usage, including:
- 🔧 Configuration
- 🔍 Troubleshooting
- 🛡️ Security
- 📊 Monitoring

Please check the [**Full Documentation**](https://atlassian.github.io/data-center-helm-charts/containers/BAMBOO-AGENT/).

---

<div align="center">

🐳🐳

</div>
