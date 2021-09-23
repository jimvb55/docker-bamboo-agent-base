ARG BASE_IMAGE=adoptopenjdk/openjdk11
FROM $BASE_IMAGE

LABEL maintainer="dc-deployments@atlassian.com"
LABEL securitytxt="https://www.atlassian.com/.well-known/security.txt"

ENV APP_NAME                                bamboo_agent
ENV RUN_USER                                bamboo
ENV RUN_GROUP                               bamboo
ENV RUN_UID                                 2005
ENV RUN_GID                                 2005

ENV BAMBOO_AGENT_HOME                       /var/atlassian/application-data/bamboo-agent
ENV BAMBOO_AGENT_INSTALL_DIR                /opt/atlassian/bamboo

WORKDIR $BAMBOO_AGENT_HOME

CMD ["/entrypoint.py"]
ENTRYPOINT ["/usr/bin/tini", "--"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends git git-lfs openssh-client python3 python3-jinja2 tini \
    && apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ARG MAVEN_VERSION=3.6.3
ENV MAVEN_HOME                              /opt/maven
RUN mkdir -p ${MAVEN_HOME} \
    && curl -L --silent http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz --strip-components=1 -C "${MAVEN_HOME}" \
    && ln -s ${MAVEN_HOME}/bin/mvn /usr/local/bin/mvn

ARG BAMBOO_VERSION
ARG DOWNLOAD_URL=https://packages.atlassian.com/maven-closedsource-local/com/atlassian/bamboo/atlassian-bamboo-agent-installer/${BAMBOO_VERSION}/atlassian-bamboo-agent-installer-${BAMBOO_VERSION}.jar

RUN groupadd --gid ${RUN_GID} ${RUN_GROUP} \
    && useradd --uid ${RUN_UID} --gid ${RUN_GID} --home-dir ${BAMBOO_AGENT_HOME} --shell /bin/bash ${RUN_USER} \
    && echo PATH=$PATH > /etc/environment \
    \
    && mkdir -p                             ${BAMBOO_AGENT_INSTALL_DIR} \
    && chown -R ${RUN_USER}:${RUN_GROUP}    ${BAMBOO_AGENT_INSTALL_DIR} \
    && curl -L --silent                     ${DOWNLOAD_URL} -o "${BAMBOO_AGENT_INSTALL_DIR}/atlassian-bamboo-agent-installer.jar" \
    && mkdir -p                             ${BAMBOO_AGENT_HOME}/conf \
    && chown -R ${RUN_USER}:${RUN_GROUP}    ${BAMBOO_AGENT_HOME}

VOLUME ["${BAMBOO_AGENT_HOME}"] # Must be declared after setting perms

COPY entrypoint.py \
     shared-components/image/entrypoint_helpers.py  /
COPY shared-components/support                      /opt/atlassian/support
COPY config/*                                       /opt/atlassian/etc/
