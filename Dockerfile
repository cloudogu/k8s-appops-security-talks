FROM cloudogu/reveal.js:3.9.2-r2 as base

FROM base as aggregator
USER root
RUN mkdir -p /dist/reveal
COPY . /dist/reveal
RUN mv /dist/reveal/resources/ /dist

FROM base
ENV TITLE='Good-Practices-for-Secure-Kubernetes-AppOps' \
    THEME_CSS='css/cloudogu-black.css'
COPY --from=aggregator --chown=nginx /dist /
