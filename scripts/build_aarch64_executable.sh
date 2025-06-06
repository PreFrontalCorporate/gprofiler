#!/usr/bin/env bash
#
# Copyright (C) 2022 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -euo pipefail

if [ "$#" -gt 0 ] && [ "$1" == "--fast" ]; then
    with_staticx=false
    shift
else
    with_staticx=true
fi

# ubuntu 20.04
UBUNTU_VERSION=@sha256:82becede498899ec668628e7cb0ad87b6e1c371cb8a1e597d83a47fac21d6af3
# rust:1.86.0-alpine3.21
PYSPY_RUST_VERSION=@sha256:541a1720c1cedddae9e17b4214075bf57c20bc7b176b4bba6bce3437c44d51ef
# rust:1.59-alpine3.15
RBSPY_RUST_VERSION=@sha256:65b63b7d003f7a492cc8e550a4830aaa1f4155b74387549a82985c8efb3d0e88
# centos 7
CENTOS7_VERSION=@sha256:43964203bf5d7fe38c6fca6166ac89e4c095e2b0c0a28f6c7c678a1348ddc7fa
# centos 8
CENTOS8_VERSION=@sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
# golang 1.16.3
GOLANG_VERSION=@sha256:f7d3519759ba6988a2b73b5874b17c5958ac7d0aa48a8b1d84d66ef25fa345f1
# alpine 3.14.2
ALPINE_VERSION=@sha256:b06a5cf61b2956088722c4f1b9a6f71dfe95f0b1fe285d44195452b8a1627de7
# mcr.microsoft.com/dotnet/sdk:6.0-focal
DOTNET_BUILDER=@sha256:749439ff7a431ab4bc38d43cea453dff9ae1ed89a707c318b5082f9b2b25fa22
# Take image from build-prepare stage
NODE_PACKAGE_BUILDER_GLIBC=build-prepare

mkdir -p build/aarch64
docker buildx build --platform=linux/arm64 \
    --build-arg PYSPY_RUST_BUILDER_VERSION=$PYSPY_RUST_VERSION \
    --build-arg RBSPY_RUST_BUILDER_VERSION=$RBSPY_RUST_VERSION \
    --build-arg PYPERF_BUILDER_UBUNTU=$UBUNTU_VERSION \
    --build-arg PERF_BUILDER_UBUNTU=$UBUNTU_VERSION \
    --build-arg PHPSPY_BUILDER_UBUNTU=$UBUNTU_VERSION \
    --build-arg AP_BUILDER_CENTOS=$CENTOS7_VERSION \
    --build-arg AP_BUILDER_ALPINE=$ALPINE_VERSION \
    --build-arg AP_CENTOS_MIN=$CENTOS7_VERSION \
    --build-arg BURN_BUILDER_GOLANG=$GOLANG_VERSION \
    --build-arg GPROFILER_BUILDER=$CENTOS8_VERSION \
    --build-arg DOTNET_BUILDER=$DOTNET_BUILDER \
    --build-arg NODE_PACKAGE_BUILDER_MUSL=$ALPINE_VERSION \
    --build-arg NODE_PACKAGE_BUILDER_GLIBC=$NODE_PACKAGE_BUILDER_GLIBC \
    --build-arg STATICX=$with_staticx \
    . -f executable.Dockerfile --output type=local,dest=build/aarch64/ "$@"
