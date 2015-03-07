FROM dictybase/bioperl
MAINTAINER Siddhartha Basu <siddhartha-basu@northwestern.edu>


ENV GOLANG_VERSION 1.4.2

RUN curl -sSL https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz \
		| tar -v -C /usr/src -xz

RUN cd /usr/src/go/src && ./make.bash --no-clean 2>&1

ADD http://download.zeromq.org/zeromq-4.0.4.tar.gz /tmp/
RUN cd /tmp && tar xvzf zeromq-4.0.4.tar.gz && \
    cd zeromq-4.0.4 && ./configure && \
    make -j7 && make install && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/zmq.conf && \
    ldconfig
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig

ENV PATH /usr/src/go/bin:$PATH

RUN mkdir -p /go/src
ENV GOPATH /go
ENV PATH /go/bin:$PATH

COPY go-wrapper /usr/local/bin/

RUN chmod 755 /usr/local/bin/go-wrapper && mkdir -p /go/src/app
WORKDIR /go/src/app

# this will ideally be built by the ONBUILD below ;)
CMD ["go-wrapper", "run"]

ONBUILD COPY . /go/src/app
ONBUILD RUN go-wrapper download
ONBUILD RUN go-wrapper install


