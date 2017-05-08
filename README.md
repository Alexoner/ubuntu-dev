# ubuntu-dev
ubuntu development environment dockerfile

## Build
```shell
docker build -t dev .
```

## Run
```shell
# launch the container in detach mode
# With the network set to host a container will share the host’s network stack and all interfaces from the host will be available to the container. The container’s hostname will match the hostname on the host system
docker run -v $HOME:/opt --net="host" -dti <image> zsh


# then enter the container and run bash with

docker exec -ti ID_of_container zsh
```
