############ ToolBox
FROM alpine:3.15.0 as toolbox
LABEL stage=toolbox

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    git \
    openssh \
    bash \
    hub