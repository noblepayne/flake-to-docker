# Alpine only used as a small build environment.
FROM alpine:latest as nix-builder

# Setup directories.
RUN mkdir /app
RUN mkdir -p /output/store

# Install nix.
RUN apk add curl \
 && curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --init none --force --no-confirm

# Preload nix store, only for dev.
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
 && nix flake show nixpkgs

# Load flake.nix and flake.lock.
COPY flake* /app

# Install flake to custom profile and copy closure.
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
 && cd /app \
 && nix profile install . --profile /output/profile \
 && cp -va $(nix path-info -r /output/profile) /output/store

# Build minimal container environment with just flake closure.
FROM scratch
COPY --from=nix-builder /output/store /nix/store
COPY --from=nix-builder /output/profile /usr/local

# Optional command.
CMD ["python3"]
