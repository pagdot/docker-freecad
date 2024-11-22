FROM debian:bookworm AS downloader
ARG FREECAD_VERSION=1.0.0

RUN apt update
RUN apt install -y wget
RUN wget https://github.com/FreeCAD/FreeCAD/releases/download/${FREECAD_VERSION}/FreeCAD_${FREECAD_VERSION}-conda-Linux-x86_64-py311.AppImage
RUN chmod +x ./FreeCAD_${FREECAD_VERSION}-conda-Linux-x86_64-py311.AppImage
RUN ./FreeCAD_${FREECAD_VERSION}-conda-Linux-x86_64-py311.AppImage --appimage-extract

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
