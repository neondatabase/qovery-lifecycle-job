FROM node:18-alpine

RUN yarn add global neonctl@v1.20.0

WORKDIR /app

RUN mkdir -p /qovery-output
RUN mkdir -p /root/.config/neonctl
RUN mkdir -p /branch_out
RUN mkdir -p /branch_err

COPY . .

ENTRYPOINT [ "/bin/sh" ]
