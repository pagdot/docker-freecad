FROM debian:bookworm AS downloader
ARG FREECAD_VERSION=1.0.0
ARG ARCH=x86_64

RUN apt update
RUN apt install -y wget curl jq
RUN curl "https://api.github.com/repos/FreeCAD/FreeCAD/releases/tags/${FREECAD_VERSION}" | \
  jq "(.assets.[] | select(.content_type == \"application/vnd.appimage\")) | select(.name | index(\"${ARCH}\")).browser_download_url" | \
  xargs wget -O FreeCad.AppImage
RUN chmod +x ./FreeCad.AppImage
RUN ./FreeCad.AppImage --appimage-extract

FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG FREECAD_VERSION=1.0.0
LABEL build_version="pag.dev version:- ${FREECAD_VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="pagdot"

# title
ENV TITLE="FreeCAD"

COPY --from=downloader /squashfs-root/ /app/

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/freecad-logo.png

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
