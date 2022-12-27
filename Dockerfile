FROM ubuntu:jammy

LABEL maintainer="gpopesc@gmail.com"

ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=us_US.UTF-8
ARG LANGUAGE=us_US.UTF-8

ENV DEBIAN_FRONTEND=${DF} \
    LANG=${LANG} \ 
    LANGUAGE=${LANGUAGE} \
    TZ=${TZ} \
    USER_NAME=${USER_NAME} \
    USER_PASSWORD=${USER_PASSWORD}

# mandatory apps
RUN apt-get update && apt-get -y install unzip \
      wget \
      curl \
      nano \
      tzdata \
      apache2 \
      php8.1 \
      php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath \
   && rm -rf /var/lib/apt/lists/*

#set working directory to where Apache serves files
WORKDIR /var/www/html
EXPOSE 80
EXPOSE 443

HEALTHCHECK --interval=1m --timeout=10s CMD curl --fail http://127.0.0.1:80

RUN wget -q -P /tmp https://afterlogic.com/download/webmail-pro-php.zip
COPY afterlogic.php /tmp 
COPY startup.sh /

RUN chmod +x /startup.sh
CMD ["/startup.sh"]

