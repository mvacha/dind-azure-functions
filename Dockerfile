FROM mcr.microsoft.com/dotnet/sdk:5.0-focal

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Azure Functions Core Tools
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt update &&  \
    apt install azure-functions-core-tools-3 -y

# Install zip
RUN apt install zip -y

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt install nodejs -y