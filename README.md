/run/user/$UID/podman/podman.sock



### podman
#### run dev server
```bash
podman build -t tszx:vanilla-dev --target dev .
podman run --rm --security-opt label=disable -v /var/run/user/1000/podman/podman.sock:/var/run/docker.sock -v .:/workspace --name myapp-dev -td tszx:vanilla-dev

```
#### as deamon
```bash
podman build -t tszx:vanilla .
podman run --rm --security-opt label=disable -v /var/run/user/1000/podman/podman.sock:/var/run/docker.sock --name myapp -dt tszx:vanilla-dev
```

### docker
**UNTESTED**
#### run dev server
```bash
docker build -f Containerfile -t tszx:vanilla-dev --target dev .
docker run --rm --security-opt label=disable -v /var/run/docker.sock:/var/run/docker.sock -v .:/workspace --name myapp-dev -td tszx:vanilla-dev

```