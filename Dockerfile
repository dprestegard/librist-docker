FROM buildpack-deps:focal as builder

ENV LIBRIST_VERSION=v0.2.0-RC3

# Get build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-pip \
        cmake \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install meson ninja

RUN git clone https://code.videolan.org/rist/librist.git --branch ${LIBRIST_VERSION} && \
    cd librist && \
    mkdir build && \
    cd build && \
    meson .. --default-library=static && \
    ninja

FROM ubuntu:focal as release

COPY --from=builder /librist/build/tools/rist2rist /usr/bin/
COPY --from=builder /librist/build/tools/ristreceiver /usr/bin/
COPY --from=builder /librist/build/tools/ristsender /usr/bin/
COPY --from=builder /librist/build/tools/ristsrppasswd /usr/bin/
