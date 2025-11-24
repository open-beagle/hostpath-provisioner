# hostpath-provisioner

<https://github.com/kubevirt/hostpath-provisioner>

```bash
git remote add upstream git@github.com:kubevirt/hostpath-provisioner.git

git fetch upstream

git merge v0.12.0
```

## debug

```bash
# golang
docker run --rm \
  -w /go/src/kubevirt.io/hostpath-provisioner \
  -v $PWD/:/go/src/kubevirt.io/hostpath-provisioner \
  registry.cn-qingdao.aliyuncs.com/wod/golang:1.24-alpine \
  bash .beagle/build.sh
```
