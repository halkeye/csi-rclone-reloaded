# syntax=docker/dockerfile:1

FROM golang:1.22 AS build-stage
ARG GITHUB_REF=latest

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
COPY . .

ENV CGO_ENABLED=0

RUN go build -a -gcflags=-trimpath=$(go env GOPATH) -asmflags=-trimpath=$(go env GOPATH) -ldflags '-X github.com/wunderio/csi-rclone/pkg/rclone.DriverVersion=${GITHUB_REF} -extldflags "-static"' -o /bin/csi-rclone-plugin ./cmd/csi-rclone-plugin

# Deploy the application binary into a lean image
FROM rclone/rclone:1.67.0
WORKDIR /
COPY --from=build-stage /bin/csi-rclone-plugin /bin/csi-rclone-plugin
CMD ["/bin/csi-rclone-plugin"]
