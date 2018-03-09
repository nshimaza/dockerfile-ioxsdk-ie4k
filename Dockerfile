# Copyright (c) 2017 Cisco and/or its affiliates.
#
# This software is licensed to you under the terms of the Cisco Sample
# Code License, Version 1.0 (the "License"). You may obtain a copy of the
# License at
#
#                https://developer.cisco.com/docs/licenses
#
# All use of the material herein must be in accordance with the terms of
# the License. All rights not expressly granted by the License are
# reserved. Unless required by applicable law or agreed to separately in
# writing, software distributed under the License is distributed on an "AS
# IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied.

FROM ubuntu:14.04.4

ADD ioxsdk-1.2.0.0.bin /opt/
RUN apt-get update && \
    apt-get install -y e2tools && \
    apt-get install -y mtools && \
    apt-get install -y bc && \
    adduser --disabled-password --gecos '' iox && \
    adduser iox sudo && \
    echo 'iox:iox' | chpasswd && \
    echo 'iox ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    chmod 777 /opt && \
    chmod +x /opt/ioxsdk-1.2.0.0.bin
USER iox
RUN cd /opt && \
    export DEBIAN_FRONTEND=noninteractive && \
    { printf 'y\n\n'; yes; } | /opt/ioxsdk-1.2.0.0.bin /opt/ioxsdk && \
    bash -c "source /opt/ioxsdk/SOURCEME && \
    iox ldsp install yocto-1.7 && \
    iox psp install ie4k && \
    git clone git://git.openembedded.org/openembedded-core -b dizzy /opt/openembedded-core && \
    git clone git://git.openembedded.org/meta-openembedded -b dizzy /opt/meta-openembedded && \
    mkdir /opt/yoctomirror && \
    iox ldsp execute yocto-1.7 project create -m /opt/yoctomirror -p yp -t ie4k-lxc && \
    cd yp && \
    source ./SOURCEME && \
    bitbake -c fetchall iox-core-image-minimal-dev && \
    mv downloads/*.{tar.gz,tgz,rpm,tar.bz2,tar.xz} /opt/yoctomirror/ && \
    cd .. && \
    rm -fr yp && \
    sudo apt-get clean"
