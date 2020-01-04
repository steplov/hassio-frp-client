ARG BUILD_FROM

FROM $BUILD_FROM

ARG BUILD_ARCH
ARG FRP_VERSION

ENV LANG C.UTF-8

WORKDIR /usr/src

# Copy data for add-on
COPY data/configure.sh /
COPY data/run.sh /

RUN chmod a+x /run.sh
RUN chmod a+x /configure.sh
RUN /configure.sh $BUILD_ARCH $FRP_VERSION
RUN rm -rf /configure.sh

CMD [ "/run.sh" ]
