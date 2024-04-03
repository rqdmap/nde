.PHONY: default

default: build run

build:
	docker build --network=host -t rqdmap/nde \
		--build-arg HTTP_PROXY="http://127.0.0.1:7890" \
		--build-arg HTTPS_PROXY="http://127.0.0.1:7890" \
		.

run:
	docker run -it rqdmap/nde:latest zsh
