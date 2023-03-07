FROM centos:centos7 as builder

ENV GOROOT=/usr/local/go
ENV GOBIN=/usr/local/go/bin
ENV GOPATH=/usr/local/go/gopath
ENV GOPROXY=https://goproxy.cn,https://goproxy.io,direct
ENV PATH=$PATH:$GOBIN:$GOPATH/bin

WORKDIR /opt

RUN  yum -y update && yum -y install wget git \
&& wget --progress=bar:force https://studygolang.com/dl/golang/go1.17.linux-amd64.tar.gz \
&& tar -zxvf go1.17.linux-amd64.tar.gz -C /usr/local \
&& rm -f go1.17.linux-amd64.tar.gz \
&& git clone https://github.com/jpillora/webproc.git \
&& cd webproc \
&& go build -o webproc -v . 

FROM centos:centos7

MAINTAINER 1716318413@qq.com

ENV DNSMASQ_CONF=/etc/dnsmasq.conf

COPY --from=builder  /opt/webproc/webproc /usr/bin/webproc

RUN yum -y install dnsmasq \
&& cp /etc/dnsmasq.conf /etc/dnsmasq.conf.default

EXPOSE 8080
EXPOSE 53

ENTRYPOINT ["webproc","-l","proxy","--configuration-file","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]