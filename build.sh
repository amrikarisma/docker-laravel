docker build --no-cache -t kentos93/php_vestora:latest . && \
docker tag kentos93/php_vestora kentos93/php_vestora:$(date +%s) && \
docker push --all-tags kentos93/php_vestora && \
docker rmi -f $(docker images -q kentos93/php_vestora)