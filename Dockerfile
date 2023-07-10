FROM ubuntu:latest

# Install required dependencies
RUN apt-get update && apt-get install -y curl gnupg2 jq grep

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarnkey.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

RUN yarn add global neonctl@v1.13.0

WORKDIR /app

RUN mkdir -p /qovery-output
RUN mkdir -p /root/.config/neonctl
RUN mkdir -p /branch_out
RUN mkdir -p /branch_err

COPY . .

ENTRYPOINT [ "/bin/sh" ]
