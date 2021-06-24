FROM mcr.microsoft.com/dotnet/core/sdk:3.1

# Repo Args
ARG gitUrl
ARG repoTag

ARG fullnodeContainerDir
ARG configFile

RUN git clone ${gitUrl} --branch ${repoTag} --single-branch  \
    && cd /blockcore/src/Node/Blockcore.Node \
    && dotnet build

WORKDIR /blockcore/src/Node/Blockcore.Node

RUN apt-get update && apt install -y libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev make g++

RUN git clone https://github.com/facebook/rocksdb.git \
    && cd rocksdb \
    && git checkout tags/v6.2.2 \
    && make shared_lib

WORKDIR /blockcore/src/Node/Blockcore.Node/rocksdb

RUN cp librocksdb.so.6.2.2 ../bin/Debug/netcoreapp3.1/

WORKDIR /blockcore/src/Node/Blockcore.Node/bin/Debug/netcoreapp3.1

RUN ln -fs librocksdb.so.6.2.2 librocksdb.so.6.2
RUN ln -fs librocksdb.so.6.2.2 librocksdb.so.6
RUN ln -fs librocksdb.so.6.2.2 librocksdb.so

WORKDIR /blockcore/src/Node/Blockcore.Node


ENTRYPOINT exec dotnet run --chain="${eTicker}" -dbtype=rocksdb -txindex
