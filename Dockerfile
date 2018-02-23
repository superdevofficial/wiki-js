FROM alpine:3.6

ENV ALPINE_VERSION=3.6

# Install needed packages. Notes:
#   * nodejs: Node.js and NPM
#   * Git: Git to store wiki-js documents
#   * Curl: Curl for downloads.
#   * nodejs-npm: Required for Wikijs install
#   * bash: Required for Wikijs install
#   * supervisor: Control starting of applications

# Set work directory for WikiJS install
WORKDIR /var/wiki

ENV PACKAGES="\
  nodejs \
  git \
  curl \
  nodejs-npm \
  bash \
  supervisor \
"

RUN apk --update add --no-cache $PACKAGES  \
    && echo

RUN VERSION=$(curl -L -s -S https://beta.requarks.io/api/version/stable) && \
  	echo "[1/3] Fetching latest build..." && \
  	curl -L -s -S https://github.com/Requarks/wiki/releases/download/v$VERSION/wiki-js.tar.gz | tar xz -C . && \
  	echo "[2/3] Fetching dependencies..." && \
  	curl -L -s -S https://github.com/Requarks/wiki/releases/download/v$VERSION/node_modules.tar.gz | tar xz -C .

RUN rm  config.sample.yml

# Create Wikijs user with no login or password
RUN adduser -h /var/wiki -D -S  wikijs

# Correct permissions on /var/wiki
RUN chown -R wikijs:nogroup /var/wiki


# Add files
ADD files/supervisord.conf /etc/supervisord.conf
# Replace your-config.yml with the path to your config file:
ADD files/config.yml /var/wiki/config.yml

# Expose port 3000 for Wikijs
EXPOSE 3000

# Entrypoint
ADD start.sh /
RUN chmod u+x /start.sh
CMD /start.sh
