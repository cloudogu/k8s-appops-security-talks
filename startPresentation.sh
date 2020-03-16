#!/usr/bin/env bash

echo "Starting presentation on localhost:8000" 

docker run --rm \
    -v $(pwd)/css/cloudogu-black.css:/reveal/css/cloudogu-black.css \
    -v $(pwd)/images:/reveal/images \
    -v $(pwd)/docs/slides:/reveal/docs/slides \
    -v $(pwd)/plugin/tagcloud:/reveal/plugin/tagcloud \
    -v $(pwd)/resources:/resources \
    -e THEME_CSS='css/cloudogu-black.css' \
    -p 8000:8000 -p 35729:35729 \
    cloudogu/reveal.js:$(head -n1 Dockerfile | sed 's/.*:\([^ ]*\) .*/\1/')-dev