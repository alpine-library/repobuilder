FROM alpinelib/base:edge
MAINTAINER ekozan

ENV ALPINE_VERSION edge

RUN apk --update add dpkg openssh-client git abuild aports-build alpine-sdk \
  && rm -rf /var/cache/apk/*

RUN adduser -S -G abuild abuild
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)"

VOLUME /repo
WORKDIR /repo
COPY auto-build.sh /usr/local/bin/auto-build
COPY docker-entrypoint.sh /entrypoint.sh

RUN mv /etc/abuild.conf /etc/abuild.conf.orig \
  && chmod +x /entrypoint.sh \
  && chown -R abuild:abuild /repo \
  && chmod +x /usr/local/bin/gosu \
  && chmod +x /usr/local/bin/auto-build

ENTRYPOINT ["/entrypoint.sh"]
CMD ["build"]
