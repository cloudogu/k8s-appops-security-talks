FROM cloudogu/reveal.js:3.9.2-r2 as base

FROM base as aggregator
USER root
RUN mkdir -p /dist/reveal
COPY . /dist/reveal
RUN mv /dist/reveal/resources/ /dist

FROM base
ENV TITLE='3 things every developer should know about K8s security' \
    THEME_CSS='css/cloudogu-black.css' \
    ADDITIONAL_DEPENDENCIES="{ src: 'plugin/tagcloud/tagcloud.js' }"
COPY --from=aggregator --chown=nginx /dist /
