FROM alpine:3.10 

MAINTAINER Caio caiomcg@gmail.com

RUN apk update
RUN apk add --no-cache git
RUN apk add --no-cache vim
RUN apk add --no-cache gcc
RUN apk add --no-cache g++
RUN apk add --no-cache gdb
RUN apk add --no-cache clang
RUN apk add --no-cache openssh-server
RUN apk add --no-cache cmake
RUN apk add --no-cache make
RUN apk add --no-cache bash-doc
RUN apk add --no-cache bash
RUN apk add --no-cache bash-completion
# TODO: Add ffmpeg build
# TODO: Add Opus Build
# TODO: Expose GDB server
# TODO: Configure VI

# For debugging
EXPOSE 22 7777

# RUN useradd -ms /bin/bash debugger
RUN mkdir -p /app
ADD . /app
WORKDIR /app

CMD ["bash"]

# To attach with debugger
# CMD ["/usr/sbin/sshd", "-D"]
