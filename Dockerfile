################################################################################
FROM eedu_dev:latest as builder

###############################################################################    

FROM ghcr.io/antelopeio/dune:latest

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt update && apt install -y gcc-11 g++-11
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 10
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 10

COPY ./Makefile /app/custom/Makefile
COPY ./genesis.json /app/custom/genesis.json
COPY ./scripts /app/custom/scripts

COPY --from=builder /tmp/eos-evm/eos-evm-node/build/bin/ /usr/local/bin
COPY --from=builder /tmp/eos-evm/eos-evm/build/evm_runtime/ /app/custom/evm_runtime

WORKDIR /app/custom

RUN git clone -b proxy-reader-method https://github.com/TruongTienBridge/eos-evm-miner.git

WORKDIR /app/custom/eos-evm-miner

RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
RUN source ~/.nvm/nvm.sh && nvm install v16 && nvm use v16 && cd /app/custom/eos-evm-miner && npm install && npm run build

WORKDIR /app

ENTRYPOINT ["/app/custom/scripts/boostrap.sh"]