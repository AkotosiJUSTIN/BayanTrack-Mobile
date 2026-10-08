ARG FLUTTER_IMAGE=ghcr.io/cirruslabs/flutter:stable
FROM ${FLUTTER_IMAGE}

WORKDIR /workspace
ENV PUB_CACHE=/root/.pub-cache

# The Compose service overrides this with an idle command. Keeping the default
# idle makes direct `docker run` use safe too.
CMD ["tail", "-f", "/dev/null"]
