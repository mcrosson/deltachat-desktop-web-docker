FROM rust:alpine AS certgen

RUN apk update && apk add build-base \
    && cargo install rustls-cert-gen \
    && rustls-cert-gen -o /opt/deltachat-certificate

FROM node:alpine

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

EXPOSE 3000

VOLUME /opt/deltachat-desktop/packages/target-browser/.env
VOLUME /opt/deltachat-desktop/packages/target-browser/data

WORKDIR /opt/deltachat-desktop

RUN apk update && apk add git curl \
    && curl -fsSL https://get.pnpm.io/install.sh | ENV="$HOME/.shrc" SHELL="$(which sh)" sh - \
    && git clone https://github.com/deltachat/deltachat-desktop /opt/deltachat-desktop

WORKDIR /opt/deltachat-desktop/packages/target-browser

COPY --from=certgen /opt/deltachat-certificate/ /opt/deltachat-certificate/

RUN pnpm install \
    && pnpm build

CMD ["pnpm", "run", "start"]
