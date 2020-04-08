FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS core-tools-build-env

RUN wget https://github.com/Azure/azure-functions-core-tools/archive/master.tar.gz && \
    tar -xzvf master.tar.gz
RUN cd azure-functions-core-tools-* && \
    dotnet publish src/Azure.Functions.Cli/Azure.Functions.Cli.csproj --runtime linux-musl-x64 --output /output

FROM docker:latest

RUN apk update && apk add bash

# Install Azure CLI
RUN apk update && apk upgrade && apk add make py-pip
RUN apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev=3.7.5-r1
RUN pip3 install azure-cli && apk del --purge build

# .NET Core dependencies
RUN apk add --no-cache \
        ca-certificates \
        \
        # .NET Core dependencies
        krb5-libs \
        libgcc \
        libintl \
        libssl1.1 \
        libstdc++ \
        lttng-ust \
        tzdata \
        userspace-rcu \
        zlib
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

# Install .NET Core
ENV DOTNET_VERSION 3.1.3
RUN wget -O dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='ce8bef0f11c552d18727d39ae5c8751cba8de70b0bb1958afa6a7f2cf7c4c1bff94a7e216c48c3c3f72f756bfcf8d5c9e5d07f90cf91263a68c5914658ae6767' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

COPY --from=core-tools-build-env [ "/output", "/azure-functions-core-tools" ]
RUN ln -s /azure-functions-core-tools/func /bin/func

