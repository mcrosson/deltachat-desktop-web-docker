# delta.chat desktop in docker container

rough info / example on how to run delta.chat desktop within docker as a web app

## dire warnings

- the delta code is pre-alpha status
- there are many caveats, see the delta chat docs before attempting to run the desktop app as a web app within docker

## seriously, this is full of caveats

- WARNING: the data folder needs to be a volume *and* have a certificate stored in a sub-directory named `certificate`
- WARNING: the `.env` volume below is a *file* -- see the main delta.chat desktop github repo for an example
- NOTE: An auto-generated cert is stored at `/opt/deltachat-certificate` in the image as part of the build -- copy this to `/opt/deltachat-desktop/packages/target-browser/data/certificate` to use
- NOTE: this will NOT run w/o a cert -- don't try to circumvent this, please

## links

- https://github.com/deltachat/deltachat-desktop/tree/main
- https://github.com/deltachat/deltachat-desktop/tree/main/packages/target-browser

## build container

``` shell
git clone https://github.com/mcrosson/deltachat-desktop-web-docker.git /opt/deltachat-desktop-web-docker
cd /opt/deltachat-desktop-web-docker
docker build -t delta-web-test:latest .
```

## copy cert to data folder

``` shell
docker run --rm -it \
    -v /var/deltachat-desktop/user-1/data:/opt/deltachat-desktop/packages/target-browser/data \
    delta-web-test:latest cp -rv /opt/deltachat-certificate /opt/deltachat-desktop/packages/target-browser/data/certificate
```

## run delta chat desktop as a browser app

note: remove `-p 3000:3000` when running behind a reverse proxy like traefik

``` shell
docker run -d \
    -p 3000:3000 \
    --name deltachat-desktop-user-1 \
    --restart unless-stopped \
    -v /var/deltachat-desktop/user-1/env:/opt/deltachat-desktop/packages/target-browser/.env \
    -v /var/deltachat-desktop/user-1/data:/opt/deltachat-desktop/packages/target-browser/data \
    delta-web-test:latest
docker logs -f --since=1m deltachat-desktop-user-1
```

## docker labels for self-hosting with traefik

note: you likely want to setup basic auth via traffic too

```
    -l diun.enable=false \
    -l "traefik.enable=true" \
    -l "traefik.http.routers.deltachat-desktop-user-1.tls" \
    -l "traefik.http.routers.deltachat-desktop-user-1.tls.certresolver=letsencrypt" \
    -l "traefik.http.routers.deltachat-desktop-user-1_insecure.entrypoints=web" \
    -l "traefik.http.routers.deltachat-desktop-user-1_insecure.rule=Host(\`deltachat-desktop-user-1.domain.tld\`)" \
    -l "traefik.http.routers.deltachat-desktop-user-1_insecure.middlewares=redirect@file" \
    -l "traefik.http.routers.deltachat-desktop-user-1.entrypoints=web-secure" \
    -l "traefik.http.routers.deltachat-desktop-user-1.rule=Host(\`deltachat-desktop-user-1.domain.tld\`)" \
    -l "traefik.http.services.deltachat-desktop-user-1.loadbalancer.server.port=3000" \
    -l "traefik.http.services.deltachat-desktop-user-1.loadbalancer.server.scheme=https" \

```


## Licensing

Unless otherwise stated all source code is licensed under the [Apache 2 License](LICENSE-APACHE-2.0.txt).

Unless otherwise stated the non source code contents of this repository are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](LICENSE-CC-Attribution-NonCommercial-ShareAlike-4.0-International.txt)
