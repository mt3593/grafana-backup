FROM node:alpine
RUN apk add --no-cache bash && \
    mkdir -p /datasources /dashboards && \
    npm install -g wizzy@0.5.9 && \
    apk add --no-cache git && \
    apk add --no-cache openssh

ENV GIT_NAME=$GIT_NAME
ENV GIT_EMAIL=$GIT_EMAIL
ENV GIT_REPO_USERNAME=$GIT_REPO_USERNAME
ENV GIT_REPO=$GIT_REPO
ENV GRAFANA_URL=$GRAFANA_URL
ENV GRAFANA_USERNAME=$GRAFANA_USERNAME
ENV GRAFANA_PASSWORD=$GRAFANA_PASSWORD

COPY /bin /usr/local/bin

ENTRYPOINT ["/usr/local/bin/backup.sh"]
