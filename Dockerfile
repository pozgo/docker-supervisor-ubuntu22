FROM ubuntu:22.04

ENV SUPERVISOR_VERSION=4.2.5 \
    SUPERVISOR_USERNAME=sv \
    SUPERVISOR_USER=supervisor \
    SUPERVISOR_UID=1000 \
    SUPERVISOR_GID=1000

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip && \
    pip3 install --no-cache-dir supervisor==${SUPERVISOR_VERSION} && \
    groupadd -g ${SUPERVISOR_GID} ${SUPERVISOR_USER} && \
    useradd -u ${SUPERVISOR_UID} -g ${SUPERVISOR_GID} -m -s /bin/bash ${SUPERVISOR_USER} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY container-files /

RUN chmod +x /config/bootstrap.sh && \
    mkdir -p /data/conf /data/run /data/logs && \
    chown -R ${SUPERVISOR_USER}:${SUPERVISOR_USER} /data

VOLUME ["/data"]

USER ${SUPERVISOR_USER}

ENTRYPOINT ["/config/bootstrap.sh"]

EXPOSE 9111