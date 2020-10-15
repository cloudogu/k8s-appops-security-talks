FROM cloudogu/reveal.js:3.9.2-r9 as base
FROM base as aggregator
ENV TITLE='Secure by Default? - Pragmatically Improve App Security Using K8s Built-Ins' \
    THEME_CSS='css/cloudogu-black.css'
USER root
COPY . /reveal
RUN mv /reveal/resources/ /
RUN /scripts/templateIndexHtml

FROM base
ENV SKIP_TEMPLATING='true'
COPY --from=aggregator --chown=nginx /reveal /reveal