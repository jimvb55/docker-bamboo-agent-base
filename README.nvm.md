# Bamboo Agent with NVM (Node Version Manager)

This Docker image provides a Bamboo agent with NVM (Node Version Manager) installed, allowing for greater flexibility when running builds that require different Node.js versions.

## Features

- Multiple Node.js versions pre-installed (18 and 20 LTS by default)
- Easy switching between Node.js versions during builds
- All Node.js versions registered as Bamboo capabilities
- Common npm packages (npm, yarn) installed for each Node.js version
- Based on Debian Bookworm for stability and compatibility

## Building the Image

```bash
docker build -f Dockerfile.nvm --build-arg BAMBOO_VERSION=10.2.1 -t bamboo-agent-nvm .
```

You can customize the build with the following build arguments:

- `BAMBOO_VERSION`: The version of Bamboo agent to install (required)
- `BASE_IMAGE`: The base image to use (default: `debian:bookworm-slim`)
- `DOWNLOAD_USERNAME` and `DOWNLOAD_PASSWORD`: Credentials for downloading the Bamboo agent installer (optional)

## Environment Variables

The image uses the following environment variables that can be customized at runtime:

- `DEFAULT_NODE_VERSION`: The default Node.js version to use (default: `20`)
- `NODE_VERSIONS`: Space-separated list of Node.js versions to install (default: `"18 20"`)

## Using Different Node.js Versions in Builds

### Method 1: Using the `use-node` Helper Script

The image includes a helper script to easily switch between Node.js versions:

```bash
# In your Bamboo build script
use-node 18  # Switch to Node.js 18
node -v      # Verify version

# Run your Node.js 18 specific commands
npm install
npm test

use-node 20  # Switch to Node.js 20
node -v      # Verify version

# Run your Node.js 20 specific commands
npm install
npm test
```

### Method 2: Using NVM Directly

You can also use NVM directly in your build scripts:

```bash
# In your Bamboo build script
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load NVM

nvm use 18
node -v      # Verify version

# Run your Node.js 18 specific commands
npm install
npm test

nvm use 20
node -v      # Verify version

# Run your Node.js 20 specific commands
npm install
npm test
```

### Method 3: Using Bamboo Capabilities

Each installed Node.js version is registered as a separate Bamboo capability. You can configure your Bamboo tasks to use specific versions by selecting the appropriate executable:

- `Node.js v18.x.x`: Points to the Node.js 18 executable
- `Node.js v20.x.x`: Points to the Node.js 20 executable
- `Node.js`: Points to the default Node.js version (as specified by `DEFAULT_NODE_VERSION`)

## Adding More Node.js Versions

You can customize the image to include additional Node.js versions by modifying the `NODE_VERSIONS` environment variable in the Dockerfile or at runtime.

### At Build Time

Modify the `NODE_VERSIONS` environment variable in the Dockerfile:

```dockerfile
ENV NODE_VERSIONS "16 18 20"
```

### At Runtime

You can also add more Node.js versions at runtime:

```bash
# Inside the container
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load NVM

# Install additional Node.js version
nvm install 16

# Register as a Bamboo capability
node_path="$NVM_DIR/versions/node/v$(node --version | cut -c 2-)/bin/node"
/bamboo-update-capability.sh "Node.js $(node --version)" "$node_path"
```

## Advantages Over Previous Approach

The previous approach used separate Docker images for each Node.js version, which had several disadvantages:

1. **Maintenance Overhead**: Required maintaining multiple Dockerfiles and images
2. **Storage Inefficiency**: Each image duplicated most of the content
3. **Limited Flexibility**: Builds requiring multiple Node.js versions needed multiple agents
4. **Version Lock-in**: Adding new Node.js versions required creating new images

The NVM-based approach addresses these issues by:

1. **Single Image**: One image supports multiple Node.js versions
2. **Efficient Storage**: Only the Node.js binaries are duplicated
3. **Runtime Flexibility**: Switch Node.js versions during a single build
4. **Easy Updates**: Add new Node.js versions without rebuilding the image
