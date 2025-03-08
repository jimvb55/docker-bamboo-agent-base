# 🚀 Bamboo Agent Mega Image

This document describes the `Dockerfile.mega` which creates a flexible Bamboo Agent with multiple build tool versions installed.

## 📋 Overview

The Mega Bamboo Agent is designed to provide maximum flexibility for build environments by including multiple versions of key build tools. All tools are installed in the `/app` directory with a structured layout for easy access and version switching.

## 🛠️ Included Tools & Versions

| Category | Tool | Versions | Installation Path |
|----------|------|----------|------------------|
| ☕ Java | OpenJDK (Adoptium) | 8, 17, 21 | `/app/java/8`, `/app/java/17`, `/app/java/21` |
| 🔧 Build Tools | Maven | 3.9.9 | `/app/maven` |
| 🟩 Node.js | Node.js & npm | 18, 20 | `/app/node/18`, `/app/node/20` |
| 🔷 .NET | .NET SDK | 8.0 | `/app/dotnet/8` |
| 📦 Version Control | Git & Git LFS | Latest | System installed |
| 🐍 Scripting | Python | 3.x | System installed |
| 🐙 Deployment | Octopus CLI | 2.0.0 | System installed |

## 🏗️ Directory Structure

```
/app
├── java/
│   ├── 8/         # OpenJDK 8
│   ├── 17/        # OpenJDK 17
│   └── 21/        # OpenJDK 21 (default)
├── maven/         # Maven 3.9.9
├── node/
│   ├── 18/        # Node.js 18 LTS
│   └── 20/        # Node.js 20 LTS (default)
└── dotnet/
    └── 8/         # .NET SDK 8.0
```

## 🔄 Version Switching

The image includes helper scripts to easily switch between different versions of Java and Node.js:

| Script | Description |
|--------|-------------|
| `use-java8` | Switch to Java 8 |
| `use-java17` | Switch to Java 17 |
| `use-java21` | Switch to Java 21 (default) |
| `use-node18` | Switch to Node.js 18 |
| `use-node20` | Switch to Node.js 20 (default) |

Example usage in a Bamboo build task:

```bash
# Switch to Java 8 for a specific build step
source use-java8
java -version

# Switch to Node.js 18 for a specific build step
source use-node18
node --version
```

## 🌐 Environment Variables

The image sets up environment variables for all tool versions:

```
JAVA_HOME_8=/app/java/8
JAVA_HOME_17=/app/java/17
JAVA_HOME_21=/app/java/21
MAVEN_HOME=/app/maven
NODE_HOME_18=/app/node/18
NODE_HOME_20=/app/node/20
DOTNET_HOME=/app/dotnet/8

# Default versions
JAVA_HOME=${JAVA_HOME_21}
NODE_HOME=${NODE_HOME_20}
```

## 🚀 Building the Image

```bash
# Build with default Bamboo version
docker build -f Dockerfile.mega --build-arg BAMBOO_VERSION=10.2.1 -t bamboo-agent-mega .

# Build with specific Bamboo version
docker build -f Dockerfile.mega --build-arg BAMBOO_VERSION=10.1.0 -t bamboo-agent-mega:10.1.0 .
```

## 🏃‍♂️ Running the Agent

```bash
# Create a volume for agent data
docker volume create --name bambooAgentMegaVolume

# Run the agent
docker run -e BAMBOO_SERVER=http://bamboo.mycompany.com/agentServer/ \
          -v bambooAgentMegaVolume:/var/atlassian/application-data/bamboo-agent \
          --name="bambooAgentMega" \
          --hostname="bambooAgentMega" \
          -d bamboo-agent-mega
```

## 🔍 Registered Capabilities

The agent automatically registers the following capabilities:

- JDK (default: Java 21)
- system.jdk.JDK 8
- system.jdk.JDK 17
- system.jdk.JDK 21
- Maven
- Maven 3
- Maven 3.9
- Node.js (default: Node.js 20)
- Node.js 18
- Node.js 20
- npm (default: npm from Node.js 20)
- npm 18
- npm 20
- .NET
- .NET 8
- Python
- Python 3
- Git
- octopusCLI

## 🛡️ Security

This image follows best practices for Docker security:
- Uses specific versions of tools rather than "latest" tags
- Runs as a non-root user
- Minimizes the number of layers
- Cleans up package manager caches

## 📝 Notes

- Java 21 is set as the default Java version
- Node.js 20 is set as the default Node.js version
- All tools are installed from official sources
- The image is based on Red Hat Universal Base Image (UBI) 9
