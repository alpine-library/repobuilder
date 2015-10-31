FROM alpinelib/base:edge
MAINTAINER ekozan

ENV ALPINE_VERSION edge

RUN apk --update add dpkg openssh-client git abuild aports-build alpine-sdk \
  && rm -rf /var/cache/apk/*

RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)"

VOLUME /repo
WORKDIR /repo
COPY docker-entrypoint.sh /entrypoint.sh

RUN adduser -S -G abuild abuild \
  && mkdir -p /var/cache/distfiles  \
  && chgrp abuild /var/cache/distfiles \
  && chmod g+w /var/cache/distfiles \
  && cp /etc/abuild.conf /etc/abuild.conf.orig \
  && chmod +x /entrypoint.sh \
  && chown -R abuild:abuild /repo \
  && chmod +x /usr/local/bin/gosu

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
