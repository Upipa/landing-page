# La versione di R viene passata come ARG da build.sh, che la legge da renv.lock
FROM rocker/r-ver:4.5.2

ENV DEBIAN_FRONTEND=noninteractive

# Dipendenze di sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    build-essential \
    pandoc \
    libproj-dev \
    libgdal-dev \
    libgeos-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

# Installa Quarto CLI
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.37/quarto-1.9.37-linux-amd64.deb \
    && dpkg -i quarto-1.9.37-linux-amd64.deb \
    && rm quarto-1.9.37-linux-amd64.deb

# Installa Microsoft ODBC Driver 18 for SQL Server
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" \
        > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && rm -rf /var/lib/apt/lists/*

# Installa solo renv; i pacchetti verranno ripristinati a runtime da entrypoint.sh
RUN R -e "install.packages('renv', repos='https://packagemanager.posit.co/cran/latest/bin/linux/manylinux_2_28-x86_64/4.5')"

# Entry point runtime
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
