############ BUILDER
FROM golang:alpine as builder
LABEL stage=builder

# Set necessary environmet variables needed for our image
## Force using Go modules even if the project is in your GOPATH. Requires go.mod to work.
ENV GO111MODULE=on
## Staticaly-linked binary
ENV CGO_ENABLED=0
## Build only for Linux/amd64
ENV GOOS=linux
ENV GOARCH=amd64

WORKDIR /go/src/app

COPY go.mod .
COPY go.sum .

# Go 1.11 introduces the "go mod download" command, which takes "go.mod" and "go.sum" files
# and downloads the dependencies from them instead of using the source code
RUN go mod download

COPY . .

RUN go build -o ./api-server api-server.go

# Reuse builder to run go test
ENTRYPOINT ["go", "test", "-v", "./..."]

############ API-SERVER
FROM alpine:3.15.0 as api-server
LABEL stage=api-server

RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /go/src/app/api-server .
USER ${USER}
EXPOSE 8080

CMD ["./api-server"]

############ SWAGGER-UI
FROM swaggerapi/swagger-ui:v4.1.2 as swagger-ui
LABEL stage=swagger-ui

ENV SWAGGER_JSON "/docs/swagger.json"
EXPOSE 8080

COPY docs/swagger.json /docs/swagger.json

CMD ["sh", "/usr/share/nginx/run.sh"]