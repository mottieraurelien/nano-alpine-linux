FROM rockylinux:9

# Extra environment variables :
ENV HOME="/root"
ENV PROFILE="$HOME/.bashrc"

# Tools :
RUN yum install -y wget

## GraalVM :
ARG JAVA_VERSION=17
ARG GRAALVM_DIRECTORY=/usr/bin/jvm
ARG GRAALVM_PACKAGE=graalvm-jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz
RUN wget https://download.oracle.com/graalvm/$JAVA_VERSION/latest/$GRAALVM_PACKAGE \
    && tar -xvzf $GRAALVM_PACKAGE -C /var/ \
    && mkdir -p $GRAALVM_DIRECTORY \
    && mv $(ls -d /var/graalvm* | tail -1 | xargs)/* $GRAALVM_DIRECTORY/ \
    && echo "export JAVA_HOME=$GRAALVM_DIRECTORY" >> $PROFILE \
    && echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $PROFILE \
    && rm -f /$GRAALVM_PACKAGE \
    && rm -rf $(ls -d /var/graalvm* | tail -1 | xargs)

# Housekeeping :
RUN yum clean all
