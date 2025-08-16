FROM nginx:latest

EXPOSE 80 443
STOPSIGNAL SIGTERM

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    nano \
    tree

CMD ["nginx", "-g", "daemon off;"]
