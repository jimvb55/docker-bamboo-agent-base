# 🚀 Bamboo Agent Java Image

This document describes the `Dockerfile.java` which creates a Java-focused Bamboo Agent with configurable JDK versions.

## 📋 Overview

The Java Bamboo Agent is designed to provide a flexible Java build environment with configurable JDK versions. All tools are installed in the `/app` directory with a structured layout for easy access and version switching.

## 🛠️ Included Tools & Versions

| Category | Tool | Version | Installation Path | Notes |
|----------|------|---------|------------------|--------|
| ☕ Java | OpenJDK (Adoptium) | 17, 21 (default) | `/app/java/17`, `/app/java/21` | Versions configurable via build arg |
| 🔧 Build Tools | Maven | 3.9.9 | `/app/maven` | Fixed version |
| 📦 Version Control | Git & Git LFS | Latest | System installed | - |
| 🐍 Scripting | Python | 3.x | System installed | - |

## 🏗️ Directory Structure

```
/app
├── java/
│   ├── 17/        # OpenJDK 17
│   └── 21/        # OpenJDK 21 (default)
└── maven/         # Maven 3.9.9
```

## 🔄 Version Switching

The image includes helper scripts to easily switch between different versions of Java:

| Script | Description |
|--------|-------------|
| `use-java17` | Switch to Java 17 |
| `use-java21` | Switch to Java 21 (default) |

Example usage in a Bamboo build task:

```bash
# Switch to Java 17 for a specific build step
source use-java17
java -version
```

## 🌐 Environment Variables

The image sets up environment variables for all tool versions:

```
JAVA_HOME_17=/app/java/17
JAVA_HOME_21=/app/java/21
MAVEN_HOME=/app/maven

# Default version (automatically set to highest installed version)
JAVA_HOME=${JAVA_HOME_21}
```

## 🚀 Building the Image

### Basic Build
```bash
# Build with default configuration
docker build -f Dockerfile.java --build-arg BAMBOO_VERSION=10.2.1 -t bamboo-agent-java .
```

### Customizing the Build

1. **Base Image Selection**:
```bash
# Use UBI8 instead of default UBI9
docker build -f Dockerfile.java \
  --build-arg BASE_IMAGE=registry.access.redhat.com/ubi8/openjdk-17:latest \
  --build-arg BAMBOO_VERSION=10.2.1 \
  -t bamboo-agent-java .
```

2. **Java Versions**:
```bash
# Install specific Java versions
docker build -f Dockerfile.java \
  --build-arg JAVA_VERSIONS="17" \
  --build-arg BAMBOO_VERSION=10.2.1 \
  -t bamboo-agent-java .

# Install multiple versions
docker build -f Dockerfile.java \
  --build-arg JAVA_VERSIONS="8 17 21" \
  --build-arg BAMBOO_VERSION=10.2.1 \
  -t bamboo-agent-java .
```


## 🏃‍♂️ Running the Agent

```bash
# Create a volume for agent data
docker volume create --name bambooAgentJavaVolume

# Run the agent
docker run -e BAMBOO_SERVER=http://bamboo.mycompany.com/agentServer/ \
          -v bambooAgentJavaVolume:/var/atlassian/application-data/bamboo-agent \
          --name="bambooAgentJava" \
          --hostname="bambooAgentJava" \
          -d bamboo-agent-java
```

## 🔍 Registered Capabilities

The agent automatically registers the following capabilities:

- system.jdk.JDK 17
- system.jdk.JDK 21
- Maven
- Maven 3
- Git
- Python
- Python 3

Note: Additional Java versions will be automatically registered if specified during build.

## 🛡️ Security

This image follows best practices for Docker security:
- Uses specific versions of tools rather than "latest" tags
- Runs as a non-root user
- Minimizes the number of layers
- Cleans up package manager caches

## 📝 Notes

- The highest installed Java version is automatically set as the default
- All Java versions are installed from Eclipse Adoptium (formerly AdoptOpenJDK)
- The image is based on Red Hat Universal Base Image (UBI) 9 by default
- Build arguments allow for flexible configuration of:
  - Base image (UBI8 or UBI9)
  - Java versions to install
  - Maven version
