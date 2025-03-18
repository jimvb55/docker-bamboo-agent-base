# Dockerfile.java - Java-focused Bamboo Agent with configurable JDK versions
ARG BASE_IMAGE=registry.access.redhat.com/ubi9/openjdk-17:latest
FROM ${BASE_IMAGE}

# Environment variables
ENV APP_NAME                                bamboo_agent
ENV RUN_USER                                bamboo
ENV RUN_GROUP                               bamboo
ENV RUN_UID                                 1002
ENV RUN_GID                                 1002

ENV BAMBOO_AGENT_HOME                       /var/atlassian/application-data/bamboo-agent
ENV BAMBOO_AGENT_INSTALL_DIR                /opt/atlassian/bamboo
ENV DISABLE_AGENT_AUTO_CAPABILITY_DETECTION false

# Create app directory for build tools
ENV APP_DIR                                 /app

# Create working directory
WORKDIR $BAMBOO_AGENT_HOME

# Copy required scripts
COPY entrypoint.py \
     probe-common.sh \
     probe-startup.sh \
     probe-readiness.sh \
     pre-launch.sh \
     shared-components/image/entrypoint_helpers.py  /
COPY shared-components/support                      /opt/atlassian/support
COPY config/*                                       /opt/atlassian/etc/
COPY bamboo-update-capability.sh                    /

# Install common dependencies
USER root
RUN microdnf upgrade -y \
             --refresh \
             --best \
             --nodocs \
             --noplugins \
             --setopt=install_weak_deps=0 \
    && microdnf update -y \
    && microdnf install -y --setopt=install_weak_deps=0 \
        git \
        git-lfs \
        openssh \
        python3 \
        python3-jinja2 \
        gzip \
        procps-ng \
        util-linux \
        which \
        wget \
        tar \
        unzip \
        ca-certificates \
        gnupg \
    && microdnf clean all \
    && mkdir -p ${APP_DIR}/java/17 ${APP_DIR}/java/21 \
       ${APP_DIR}/maven

# Arguments for tool versions
ARG JAVA_VERSIONS="17 21"
ARG MAVEN_VERSIONS="3.9.9"

# Install Java versions using Adoptium API
RUN for version in ${JAVA_VERSIONS}; do \
        curl -L "https://api.adoptium.net/v3/binary/latest/${version}/ga/linux/x64/jdk/hotspot/normal/eclipse" \
        -o /tmp/jdk${version}.tar.gz \
        && tar -xzf /tmp/jdk${version}.tar.gz -C ${APP_DIR}/java/${version} --strip-components=1 \
        && rm /tmp/jdk${version}.tar.gz; \
    done

# Install Maven versions
RUN for version in ${MAVEN_VERSIONS}; do \
        curl -L --silent https://archive.apache.org/dist/maven/maven-3/${version}/binaries/apache-maven-${version}-bin.tar.gz \
        | tar -xz --strip-components=1 -C "${APP_DIR}/maven" \
        && ln -s ${APP_DIR}/maven/bin/mvn /usr/local/bin/mvn; \
    done

ARG BAMBOO_VERSION
ENV BAMBOO_VERSION                          ${BAMBOO_VERSION}
ARG DOWNLOAD_URL=https://packages.atlassian.com/mvn/maven-atlassian-external/com/atlassian/bamboo/atlassian-bamboo-agent-installer/${BAMBOO_VERSION}/atlassian-bamboo-agent-installer-${BAMBOO_VERSION}.jar

# Setup user and download Bamboo agent
RUN groupadd --gid ${RUN_GID} ${RUN_GROUP} \
    && useradd -M --uid ${RUN_UID} --gid ${RUN_GID} --home-dir ${BAMBOO_AGENT_HOME} --shell /bin/bash ${RUN_USER} \
    && echo PATH=$PATH > /etc/environment \
    \
    && mkdir -p                             ${BAMBOO_AGENT_INSTALL_DIR} \
    && chown -R ${RUN_USER}:root            ${BAMBOO_AGENT_INSTALL_DIR} \
    && curl -L --silent                     ${DOWNLOAD_URL} -o "${BAMBOO_AGENT_INSTALL_DIR}/atlassian-bamboo-agent-installer.jar" \
    && jar -tf                              "${BAMBOO_AGENT_INSTALL_DIR}/atlassian-bamboo-agent-installer.jar" \
    && mkdir -p                             ${BAMBOO_AGENT_HOME}/conf ${BAMBOO_AGENT_HOME}/bin

# Register Java capabilities
RUN for version in ${JAVA_VERSIONS}; do \
        /bamboo-update-capability.sh "system.jdk.JDK ${version}" ${APP_DIR}/java/${version}/bin/java; \
    done \
    && /bamboo-update-capability.sh "Maven" ${APP_DIR}/maven/bin/mvn \
    && /bamboo-update-capability.sh "Maven 3" ${APP_DIR}/maven/bin/mvn \
    && /bamboo-update-capability.sh "Git" /usr/bin/git \
    && /bamboo-update-capability.sh "Python" /usr/bin/python3 \
    && /bamboo-update-capability.sh "Python 3" /usr/bin/python3 \
    && chown -R ${RUN_USER}:root ${BAMBOO_AGENT_HOME} \
    && chmod -R 770 ${BAMBOO_AGENT_HOME} \
    && for file in "/opt/atlassian/support /entrypoint.py /entrypoint_helpers.py /probe-common.sh /probe-startup.sh /probe-readiness.sh /pre-launch.sh /bamboo-update-capability.sh"; do \
       chmod -R "u=rwX,g=rX,o=rX" ${file} && \
       chown -R root ${file}; done

# Set environment variables for Java versions
RUN for version in ${JAVA_VERSIONS}; do \
        echo "export JAVA_HOME_${version}=${APP_DIR}/java/${version}" >> /etc/environment; \
    done

ENV MAVEN_HOME=${APP_DIR}/maven

# Set default Java version to the highest version
RUN latest_version=$(echo ${JAVA_VERSIONS} | tr ' ' '\n' | sort -nr | head -n1) \
    && echo "export JAVA_HOME=\${JAVA_HOME_${latest_version}}" >> /etc/environment

# Add all tool directories to PATH
ENV PATH="${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${PATH}"

# Create helper scripts to switch between versions
RUN for version in ${JAVA_VERSIONS}; do \
        echo '#!/bin/bash' > /usr/local/bin/use-java${version} \
        && echo "export JAVA_HOME=\${JAVA_HOME_${version}}" >> /usr/local/bin/use-java${version} \
        && echo 'export PATH=${JAVA_HOME}/bin:${PATH}' >> /usr/local/bin/use-java${version} \
        && chmod +x /usr/local/bin/use-java${version}; \
    done

CMD ["/entrypoint.py"]
ENTRYPOINT ["/pre-launch.sh"]
