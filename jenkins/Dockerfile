FROM rockylinux:9

# Extra environment variables :
ENV HOME="/root"
ENV PROFILE="$HOME/.bashrc"

# Tools :
RUN yum install -y git wget

## GraalVM :
ARG JAVA_VERSION=17
ARG GRAALVM_DIRECTORY=/usr/bin/jvm
ARG GRAALVM_PACKAGE=graalvm-jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz
RUN wget https://download.oracle.com/graalvm/$JAVA_VERSION/latest/$GRAALVM_PACKAGE \
    && tar -xzf $GRAALVM_PACKAGE -C /var/ \
    && mkdir -p $GRAALVM_DIRECTORY \
    && mv $(ls -d /var/graalvm-jdk-* | tail -1 | xargs)/* $GRAALVM_DIRECTORY/ \
    && echo "export JAVA_HOME=$GRAALVM_DIRECTORY" >> $PROFILE \
    && echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $PROFILE \
    && rm -f /$GRAALVM_PACKAGE \
    && rm -rf $(ls -d var/graalvm-jdk-* | tail -1 | xargs)

# Maven :
ARG MAVEN_VERSION=3.9.4
ARG MAVEN_DIRECTORY=/usr/bin/maven
ARG MAVEN_PACKAGE=apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/$MAVEN_PACKAGE \
    && tar -xzf $MAVEN_PACKAGE -C /var/ \
    && mkdir -p $MAVEN_DIRECTORY \
    && mv $(ls -d /var/apache-maven-* | tail -1 | xargs)/* $MAVEN_DIRECTORY/ \
    && mkdir -p $HOME/.m2/repository \
    && echo "export MAVEN_HOME=$MAVEN_DIRECTORY" >> $PROFILE \
    && echo "export PATH=\$PATH:\$MAVEN_HOME/bin" >> $PROFILE \
    && rm -f /$MAVEN_PACKAGE \
    && rm -rf $(ls -d /var/apache-maven-* | tail -1 | xargs)

# Housekeeping :
RUN yum clean all
