# hostpath-provisioner

<https://github.com/kubevirt/hostpath-provisioner>

```bash
git remote add upstream git@github.com:kubevirt/hostpath-provisioner.git

git fetch upstream

git merge v0.10.0
```

## debug

```bash
# golang
docker run -it --rm \
-v /go/pkg/:/go/pkg \
-w /go/src/kubevirt.io/hostpath-provisioner \
-v $PWD/:/go/src/kubevirt.io/hostpath-provisioner \
-e CI_WORKSPACE=/go/src/kubevirt.io/hostpath-provisioner \
-e PLUGIN_BINARY=hostpath-provisioner \
-e PLUGIN_MAIN=cmd/provisioner \
registry.cn-qingdao.aliyuncs.com/wod/devops-go-arch:1.17.3-bullseye

# patch
git format-patch -1 $COMMITID
```
