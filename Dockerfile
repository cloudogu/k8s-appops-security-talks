FROM cloudogu/reveal.js:3.9.2-r5 as base

FROM base as aggregator
ENV TITLE='Good-Practices-for-Secure-Kubernetes-AppOps' \
    THEME_CSS='css/cloudogu-black.css'
USER root
COPY . /reveal
RUN mv /reveal/resources/ /
RUN /scripts/templateIndexHtml

FROM base
ENV SKIP_TEMPLATING='true'
COPY --from=aggregator --chown=nginx /reveal /reveal