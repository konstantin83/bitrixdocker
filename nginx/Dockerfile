FROM nginx:latest

EXPOSE 80 443
STOPSIGNAL SIGTERM

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    zsh \
    nano

RUN chsh -s $(which zsh) \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    /usr/bin/zsh

CMD ["nginx", "-g", "daemon off;"]
