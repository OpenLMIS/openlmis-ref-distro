FROM python:3.6

# Superset version
ARG SUPERSET_VERSION=0.29.0rc7

# Superset-patchup (Ketchup) version
ARG SUPERSET_PATCHUP_VERSION=v0.1.7

# Default Superset files dir
ARG APP_DIR=/usr/local/lib/python3.6/site-packages/superset

# Configure environment
ENV GUNICORN_BIND=0.0.0.0:8088 \
    GUNICORN_LIMIT_REQUEST_FIELD_SIZE=0 \
    GUNICORN_LIMIT_REQUEST_LINE=0 \
    GUNICORN_TIMEOUT=60 \
    GUNICORN_WORKERS=2 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_REPO=apache/superset \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_PATCHUP_VERSION=${SUPERSET_PATCHUP_VERSION} \
    SUPERSET_PATCHUP_REPO=https://github.com/OpenLMIS/superset-patchup.git@${SUPERSET_PATCHUP_VERSION} \
    SUPERSET_HOME=/var/lib/superset \
    APP_DIR=${APP_DIR}
ENV GUNICORN_CMD_ARGS="--workers ${GUNICORN_WORKERS} --timeout ${GUNICORN_TIMEOUT} --bind ${GUNICORN_BIND} --limit-request-line ${GUNICORN_LIMIT_REQUEST_LINE} --limit-request-field_size ${GUNICORN_LIMIT_REQUEST_FIELD_SIZE}"

COPY requirements.txt requirements.txt

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir /etc/superset  && \
    mkdir ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset ${SUPERSET_HOME} && \
    apt-get update && \
    apt-get install -y \
        rsync \
        build-essential \
        curl \
        default-libmysqlclient-dev \
        freetds-bin \
        freetds-dev \
        postgresql-client \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl1.0 && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    pip install --no-cache-dir -r requirements.txt && \
    rm requirements.txt && \
    pip install --no-cache-dir \
        flask-cors==3.0.3 \
        flask-mail==0.9.1 \
        flask-JWT-Extended==3.18.2 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.5 \
        requests-oauthlib==1.1.0 \
        gevent==1.2.2 \
        impyla==0.14.0 \
        infi.clickhouse-orm==1.0.2 \
        psycopg2-binary==2.8.3 \
        pyathena==1.2.5 \
        pybigquery==0.4.10 \
        pyhive==0.5.1 \
        pyldap==2.4.28 \
        redis==2.10.5 \
        sqlalchemy-clickhouse==0.1.5.post0 \
        sqlalchemy-redshift==0.7.1 \
        werkzeug==0.16.1 && \
    pip install --no-cache-dir git+${SUPERSET_PATCHUP_REPO} && \
    pip uninstall -y apache-superset && \
    pip install superset==${SUPERSET_VERSION} && \
    pip uninstall -y sqlalchemy pandas && \
    pip install sqlalchemy==1.2.18 pandas==0.23.4

# Node & npm
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=v10.13.0

RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash
RUN . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH=$NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

RUN node -v
RUN npm -v

# Installing dependecies via npm
RUN npm install -g yarn
RUN npm install -g po2json

# Fetching dependecies and first build
RUN wget -P /tmp https://github.com/apache/superset/archive/${SUPERSET_VERSION}.zip \
    && unzip /tmp/${SUPERSET_VERSION}.zip -d /tmp \
    && rsync -a \
        --remove-source-files \
        --chown=superset:superset \
        /tmp/superset-${SUPERSET_VERSION}/superset/assets $APP_DIR \
    && rm -r /tmp/${SUPERSET_VERSION}.zip
RUN cd $APP_DIR/assets && yarn install

# JS building time tweaks
RUN mkdir -p /home/superset/.cache
RUN rsync -a \
  --remove-source-files \
  --chown=superset:superset \
  /usr/local/share/.cache/yarn /home/superset/.cache

# Configure Filesystem
RUN find ${APP_DIR} \! -type l -print0 | xargs -0 chown superset:superset
COPY superset /usr/local/bin
VOLUME /etc/superset \
       /var/lib/superset
WORKDIR $APP_DIR

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "superset:app"]
USER superset
