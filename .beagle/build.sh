#!/bin/bash

set -e

# 参数配置
GOARCHS="${GOARCHS:-amd64,arm64}"
BINARY="${BINARY:-hostpath-provisioner}"
MAIN="${MAIN:-cmd/provisioner}"
GOOS="${GOOS:-linux}"

# 版本信息
BUILD_VERSION="${BUILD_VERSION:-v0.12.0}"
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE=$(date -u '+%Y-%m-%d_%H:%M:%S')

# 输出目录
DIST_DIR="./dist"
mkdir -p ${DIST_DIR}

# 标记是否应用了 patch
PATCH_APPLIED=false

# 应用 patch（如果存在且未应用）
if [ -f ".beagle/v0.12-provisioner.patch" ]; then
    if ! git apply --check .beagle/v0.12-provisioner.patch 2>/dev/null; then
        echo "Patch already applied or not applicable, skipping..."
    else
        echo "Applying patch..."
        git apply .beagle/v0.12-provisioner.patch
        PATCH_APPLIED=true
        echo "✓ Patch applied successfully"
    fi
fi

# 清理函数：撤销 patch
cleanup() {
    if [ "$PATCH_APPLIED" = true ]; then
        echo ""
        echo "Reverting patch..."
        git apply -R .beagle/v0.12-provisioner.patch 2>/dev/null || true
        echo "✓ Patch reverted"
    fi
}

# 注册退出时的清理函数
trap cleanup EXIT

# 分割架构列表
IFS=',' read -ra ARCH_ARRAY <<< "$GOARCHS"

echo "Building Go binary: ${BINARY}"
echo "Main package: ${MAIN}"
echo "Target OS: ${GOOS}"
echo "Target architectures: ${GOARCHS}"
echo "Version: ${BUILD_VERSION}"
echo "Git Commit: ${GIT_COMMIT}"
echo "Build Date: ${BUILD_DATE}"
echo "---"

# 遍历每个架构进行编译
for ARCH in "${ARCH_ARRAY[@]}"; do
    OUTPUT="${DIST_DIR}/${BINARY}-${GOOS}-${ARCH}"
    
    echo "Building for ${GOOS}/${ARCH}..."
    
    # 构建 ldflags，注入版本信息
    LDFLAGS="-w -s"
    LDFLAGS="${LDFLAGS} -X 'main.appVersion=${BUILD_VERSION}'"
    LDFLAGS="${LDFLAGS} -X 'main.gitCommit=${GIT_COMMIT}'"
    LDFLAGS="${LDFLAGS} -X 'main.buildDate=${BUILD_DATE}'"
    
    CGO_ENABLED=0 \
    GOOS=${GOOS} \
    GOARCH=${ARCH} \
    go build -a -installsuffix cgo \
        -buildvcs=false \
        -ldflags="${LDFLAGS}" \
        -o ${OUTPUT} \
        ./${MAIN}
    
    # 检查编译是否成功
    if [ -f "${OUTPUT}" ]; then
        echo "✓ Successfully built: ${OUTPUT}"
        ls -lh ${OUTPUT}
    else
        echo "✗ Failed to build: ${OUTPUT}"
        exit 1
    fi
    
    echo "---"
done

echo "All builds completed successfully!"
