This is the source for github pages. Please see 
* [The GitHub Page](https://cloudogu.github.io/k8s-appops-security-talks) or
* [The Repo Source](https://github.com/cloudogu/k8s-appops-security-talks) 

# Development of this page

```bash
docker run --rm \
    -e SKIP_TEMPLATING=true \
    -v $(pwd)/index.html:/reveal/index.html \
    -v $(pwd)/images:/reveal/images \
    -v $(pwd)/2020-03-18-javaLand:/reveal/2020-03-18-javaLand \
    -p 8000:8000 -p 35729:35729 \
    cloudogu/reveal.js:3.9.2-r3-dev
```
