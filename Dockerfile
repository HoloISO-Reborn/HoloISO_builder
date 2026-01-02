# check=skip=FromPlatformFlagConstDisallowed
FROM --platform=linux/amd64 archlinux:base

# Docker builder for holoiso, it basicaly setups base arch for archiso and buildroot building.

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm git bash sudo btrfs-progs archiso arch-install-scripts git grub && \
    pacman -Scc --noconfirm

RUN useradd -m build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER build
WORKDIR /home/build

# Add a build argument to invalidate the cache
ARG CACHE_BUST=1
ARG BRANCH=""
ARG SKIP_UPDATE_BUILD=0
ARG SKIP_INSTALLER_BUILD=0
ARG TYPE="full"

# Use the argument in the RUN commands to force uncaching
RUN git clone https://github.com/HoloISO-Reborn/buildroot /home/build/buildroot && \
    echo Cache bust: $CACHE_BUST
RUN git clone https://github.com/HoloISO-Reborn/postcopy -b $BRANCH /home/build/buildroot/postcopy_beta && \
    echo Cache bust: $CACHE_BUST
RUN git clone https://github.com/HoloISO-Reborn/installer-image-beta /home/build/installer-image-beta && \
    echo Cache bust: $CACHE_BUST

    
RUN sudo chmod +x /home/build/buildroot/build.sh
RUN sudo chmod +x /home/build/installer-image-beta/build.sh
    
RUN echo $BRANCH > /home/build/branch
RUN echo $SKIP_UPDATE_BUILD > /home/build/skip_update_build
RUN echo $SKIP_INSTALLER_BUILD > /home/build/skip_installer_build
RUN echo $TYPE > /home/build/type

COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

RUN echo "Builder Ready!"
CMD ["/entrypoint.sh"]
