FROM bitnami/nginx:1.14.2-r9
# Note that .dockerignore excludes all development files
COPY . /app
