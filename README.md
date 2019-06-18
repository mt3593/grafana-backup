# Grafana backup

Using wizzy and git, this simple tool pulls down the current dashboards and
datasource configuration in Grafana. Then saves these into the git repo of your
choice.

## Use

### Docker

Run as a docker file:

```bash
docker run --env GIT_NAME="Robot" --env GIT_EMAIL="robot@example.com" \
           --env GIT_TOKEN_USERNAME="<username>" --env GIT_TOKEN="<token>" \
           --env GIT_REPO_USERNAME="<username-of-repo>" --env GIT_REPO="<repo>" 
           --env GRAFANA_URL="http://grafana" --env GRAFANA_USERNAME="admin"
           --env GRAFANA_PASSWORD="admin" mt3593/grafana-backup:v0.0.1
```

Where `GIT_REPO_USERNAME` is the user name of the repo, so for this one it would
be `mt3593`.

[dockerhub link](https://cloud.docker.com/repository/docker/mt3593/grafana-backup)

### k8s

To run as a `cronJob` in a kubernetes cluster:

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: grafana-backup
spec:
  schedule: "*/30 * * * *"
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: grafana-backup
            image: mt3593/grafana-backup:v0.0.3
            env:
              - name: GIT_NAME
                value: "Robot"
              - name: GIT_EMAIL
                value: "robot-ci@tech.com"
              - name: GIT_TOKEN_USERNAME
                valueFrom:
                  secretKeyRef:
                    name: grafana-git-backup
                    key: username
              - name: GIT_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: grafana-git-backup
                    key: token
              - name: GIT_REPO_USERNAME
                value: "<git repo username, example: mt3593>"
              - name: GIT_REPO
                value: "<repo name example: grafana-backup>"
              - name: GRAFANA_URL
                value: "http://grafana:3000"
              - name: GRAFANA_USERNAME
                valueFrom:
                  secretKeyRef:
                    name: grafana-backup-user
                    key: username
              - name: GRAFANA_PASSWORD
                valueFrom:
                  secretKeyRef:
                    name: grafana-backup-user
                    key: password
          restartPolicy: Never
```

This expects two secrets to be stored in kubernetes under the same namespace,
`grafana-backup-user` and `grafana-git-backup`. 

These can be created running the following commands with your values for username, token and password substituted in.

```bash
kubemonitoring create secret generic grafana-git-backup --from-literal=username=<username> --from-literal=token=<token>
kubemonitoring create secret generic grafana-backup-user --from-literal=username=<username> --from-literal=password=<password>
```
