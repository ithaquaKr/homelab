ARG PG_VERSION

FROM postgres:${PG_VERSION}
ENV PATH=${PATH}:/usr/lib/postgresql/11/bin
RUN apt-get update -y \
    && apt-get install -y python3.9 python3.9-dev python3-pip rsync ssh vim libpq-dev \
    && pip3 install psycopg2-binary==2.9.3 \
    && pip3 install patroni[etcd]==2.1.4 \
    && pip3 install patroni[consul]==2.1.4 \
    && apt-get install -y python3-six \
    && apt-get remove -y python3-pip \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /root/.cache
COPY launch.sh callbacks.sh /
CMD ["/bin/sh", "/launch.sh"]
