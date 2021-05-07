FROM library/debian:buster-slim as builder

ARG BW_VERSION=1.14.0

RUN apt-get update -q && apt-get install -q -y --no-install-recommends wget unzip ca-certificates

RUN cd /tmp && wget https://github.com/bitwarden/cli/releases/download/v${BW_VERSION}/bw-linux-${BW_VERSION}.zip && \
    unzip /tmp/bw-linux-${BW_VERSION}.zip && \
    chmod +x bw

FROM library/debian:buster-slim

COPY --from=builder /tmp/bw /bw

# Create an app user so our program doesn't run as root.
RUN groupadd -r noroot &&\
    useradd -r -g noroot -d /bwcli -s /sbin/nologin -c "Docker image user" noroot &&\
    mkdir -p /bwcli && chown -R noroot:noroot /bwcli

# Set the home directory to our app user's home.
ENV HOME=/bwcli

WORKDIR /bwcli
USER noroot

ENTRYPOINT [ "/bw" ]
CMD [ "--help" ]