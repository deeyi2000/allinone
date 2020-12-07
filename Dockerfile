FROM golang:alpine AS builder
WORKDIR /
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories &&\
    apk add --no-cache git make &&\
    go env -w GOPROXY=https://goproxy.cn,direct &&\
    git clone https://github.com/p4gefau1t/trojan-go.git -b master --depth=1 &&\
    cd trojan-go &&\
    make &&\

FROM alpine:latest
WORKDIR /
COPY --from=builder /trojan-go/build /usr/local/bin/
#COPY --from=builder /trojan-go/example/server.json /etc/trojan-go/config.json
ADD server.json /etc/trojan-go/config.json
RUN wget -O /etc/trojan-go/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat &&\
	wget -O /etc/trojan-go/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

CMD ["/usr/local/bin/trojan-go", "-config", "/etc/trojan-go/config.json"]