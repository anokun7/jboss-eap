FROM centos:8
ENV ADMIN_USER=admin \
    ADMIN_PASSWORD=pass$word123 \
    JDK_VERSION=jdk1.8.0_191 \
    JBOSS_USER=jboss \
    JBOSS_USER_HOME=/home/jboss \
    DOWNLOAD_BASE_URL=https://github.com/daggerok/jboss-eap-7.0/releases/download \
    JBOSS_EAP_PATCH=7.0.9 \
    JBOSS_HOME=/home/jboss/jboss-eap-7.0 \
    ARCHIVES_BASE_URL=https://github.com/daggerok/jboss-eap-7.0/releases/download/archives \
    PATCHES_BASE_URL=https://github.com/daggerok/jboss-eap-7.0/releases/download/7.0.9 \
    PATH=/home/jboss/jboss-eap-7.0/bin:/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    JAVA_HOME=/usr/lib/jvm/jdk1.8.0_191
USER root
RUN yum update -y && \
     yum update --security -y && \
     yum install -y wget ca-certificates unzip sudo unzip zip net-tools && \
     echo "${JBOSS_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
     adduser -U -m -d /home/jboss -s /bin/bash jboss && \
     usermod -a -G ${JBOSS_USER} ${JBOSS_USER}
USER jboss
WORKDIR /tmp
ADD --chown=jboss ./install.sh .
RUN wget ${ARCHIVES_BASE_URL}/${JDK_VERSION}.tar.gz -q --no-cookies --no-check-certificate -O /tmp/${JDK_VERSION}.tar.gz && \
     sudo mkdir -p /usr/lib/jvm && \
     sudo tar xzfz /tmp/${JDK_VERSION}.tar.gz -C /usr/lib/jvm/ && \
     wget ${ARCHIVES_BASE_URL}/jce_policy-8.zip -q --no-cookies --no-check-certificate -O /tmp/jce_policy-8.zip && \
     unzip -q /tmp/jce_policy-8.zip -d /tmp && \
     wget ${ARCHIVES_BASE_URL}/jboss-eap-7.0.0.zip -q --no-cookies --no-check-certificate -O /tmp/jboss-eap-7.0.0.zip && \
     unzip -q /tmp/jboss-eap-7.0.0.zip -d ${JBOSS_USER_HOME} && \
     add-user.sh ${ADMIN_USER} ${ADMIN_PASSWORD} --silent && \
     echo 'JAVA_OPTS="-Djava.net.preferIPv4Stack=true -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0" ' >> ${JBOSS_HOME}/bin/standalone.conf && \
     sudo yum autoremove -y && \
     sudo yum clean all -y && \
     sudo rm -rf /tmp/*.zip /tmp/*.tar.gz /var/cache/yum && \
     ( standalone.sh --admin-only & \
     ( sudo chmod +x /tmp/install.sh && \
     install.sh && \
     rm -rf /tmp/install.sh ) )
WORKDIR /home/jboss
EXPOSE 8080 8443 9990
ENTRYPOINT ${JBOSS_HOME}/bin/standalone.sh
