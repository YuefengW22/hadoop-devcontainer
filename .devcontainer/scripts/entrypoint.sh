#!/usr/bin/env bash
set -euo pipefail

ROLE="${ROLE:-client}"
HADOOP_USER="${HADOOP_USER:-client}"

# 确保目录权限（volume 首次挂载可能是 root）
chown -R "${HADOOP_USER}:${HADOOP_USER}" /data /var/log/hadoop || true

run() { exec gosu "${HADOOP_USER}" "$@"; }
bg()  { gosu "${HADOOP_USER}" "$@" & }

case "${ROLE}" in
  namenode)
    if [ ! -d /data/nn/current ]; then
      echo "[NN] formatting..."
      gosu "${HADOOP_USER}" hdfs namenode -format -nonInteractive
    fi
    echo "[NN] starting..."
    run hdfs namenode
    ;;

  resourcemanager)
    echo "[RM] starting..."
    run yarn resourcemanager
    ;;

  worker)
    echo "[WORKER] starting DataNode + NodeManager..."
    bg hdfs datanode
    bg yarn nodemanager
    # 保持容器前台：等待任意子进程退出
    wait -n
    exit $?
    ;;

  client)
    echo "[CLIENT] ready. Attach with: docker exec -it client bash"
    exec bash
    ;;

  *)
    echo "Unknown ROLE=${ROLE}. Use: namenode|resourcemanager|worker|client"
    exit 1
    ;;
esac
