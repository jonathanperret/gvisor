FROM golang:1.24.1 AS build

COPY . /gvisor

WORKDIR /gvisor

RUN go mod download

RUN mkdir out && CGO_ENABLED=0 GO111MODULE=on go build -o out ./...

FROM debian:12 AS run

COPY --from=build /gvisor/out/runsc /usr/local/bin/runsc

RUN useradd -s /bin/bash -m paul

USER paul

CMD runsc --debug --debug-log /tmp/logs/ -rootless -unprivileged --ignore-cgroups --directfs=true --network none do ls /tmp
