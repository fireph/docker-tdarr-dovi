FROM haveagitgat/tdarr_node:latest AS build

ARG DOVI_TOOL_TAG
ARG HDR10PLUS_TOOL_TAG
ARG MP4BOX_TAG

RUN \
  apt-get update && \
  apt-get install -y \
    build-essential \
    git \
    pkg-config \
    wget \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# MP4BOX
RUN \
  git clone --depth 1 --branch ${MP4BOX_TAG} https://github.com/gpac/gpac.git && \
  cd gpac && \
  ./configure --static-bin && \
  make -j $(nproc) && \
  make install

# DOVI_TOOL
RUN \
  wget -O - "https://github.com/quietvoid/dovi_tool/releases/download/${DOVI_TOOL_TAG}/dovi_tool-${DOVI_TOOL_TAG}-x86_64-unknown-linux-musl.tar.gz" | \
  tar -zx -C /usr/local/bin/

# HDR10PLUS_TOOL
RUN \
  wget -O - "https://github.com/quietvoid/hdr10plus_tool/releases/download/${HDR10PLUS_TOOL_TAG}/hdr10plus_tool-${HDR10PLUS_TOOL_TAG}-x86_64-unknown-linux-musl.tar.gz" | \
  tar -zx -C /usr/local/bin/

FROM haveagitgat/tdarr_node:latest

COPY --from=build --chmod=755 /usr/local/bin/dovi_tool /usr/local/bin/
COPY --from=build --chmod=755 /usr/local/bin/hdr10plus_tool /usr/local/bin/

COPY --from=build /usr/local/lib/libgpac_static.a /usr/local/lib/
COPY --from=build --chmod=755 /usr/local/bin/MP4Box /usr/local/bin/gpac /usr/local/bin/
