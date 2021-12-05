############ BUILDER
FROM golang:alpine as builder
LABEL stage=builder

WORKDIR /go/src/app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN go build -o ./run .
RUN

############ API-SERVER
FROM alpine:3.15.0 as api-server
LABEL stage=api-server

RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /go/src/app/run .
USER ${USER}
EXPOSE 8080

CMD ["./run"]

############ SWAGGER-UI
FROM swaggerapi/swagger-ui:v4.1.2 as swagger-ui
LABEL stage=swagger-ui

ENV SWAGGER_JSON "/docs/swagger.json"
EXPOSE 8080

COPY docs/swagger.json /docs/swagger.json

CMD ["sh", "/usr/share/nginx/run.sh"]