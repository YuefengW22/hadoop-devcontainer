# syntax=docker/dockerfile:1.6
FROM eclipse-temurin:11-jre-jammy

ARG HADOOP_VERSION=3.3.6

ENV HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/etc/hadoop \
    PATH=/opt/hadoop/bin:/opt/hadoop/sbin:$PATH

# 基础工具：tini + curl + bash + gosu(切换用户)
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash curl ca-certificates tini gosu procps iputils-ping net-tools git \
    && rm -rf /var/lib/apt/lists/*

# Hadoop 安装
RUN curl -fsSL "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
  | tar -xz -C /opt \
 && ln -s "/opt/hadoop-${HADOOP_VERSION}" /opt/hadoop \
 && mkdir -p /etc/hadoop /data/nn /data/dn /var/log/hadoop

# 用户
RUN useradd -m -s /bin/bash client \
 && chown -R client:client /etc/hadoop /data /var/log/hadoop /opt/hadoop*

COPY .devcontainer/scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini","--","/entrypoint.sh"]
