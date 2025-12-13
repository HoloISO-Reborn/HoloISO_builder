FROM archlinux:base

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm git bash sudo btrfs-progs archiso arch-install-scripts && \
    pacman -Scc --noconfirm

RUN useradd -m build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER build
WORKDIR /home/build

# Add a build argument to invalidate the cache
ARG CACHE_BUST=1

# Use the argument in the RUN commands to force uncaching
RUN git clone https://github.com/HoloISO-Reborn/buildroot /home/build/buildroot && \
    echo Cache bust: %CACHE_BUST%
RUN git clone https://github.com/HoloISO/postcopy -b beta /home/build/buildroot/postcopy_beta && \
    echo Cache bust: %CACHE_BUST%

RUN chmod +x /home/build/buildroot/build.sh
RUN echo "Builder Ready!"
#COPY run.sh /run.sh
#RUN sudo chmod +x /run.sh

#CMD ["/run.sh"]

CMD [ \
    "sudo", \
    "/home/build/buildroot/build.sh", \
    "--flavor", "beta", \
    "--snapshot_ver", "cos-v1", \
    "--workdir", "build", \
    "--output-dir", "/mnt/holoiso-images", \
    "--add-release" \
]
