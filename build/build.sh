#!/usr/bin/env bash
# 构建脚本：Nuitka 编译 → fpm 打包 .deb 和 .pkg.tar.zst
# 依赖工具：python-nuitka, fpm (gem install fpm), patchelf, ccache(可选)
# 运行位置：从 Cluster/ 根目录执行，或脚本自动切换

set -euo pipefail

# ── 路径 ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$ROOT_DIR/controller/src"
DIST_DIR="$ROOT_DIR/build/dist"
STAGE_DIR="$ROOT_DIR/build/stage"
PKG_DIR="$ROOT_DIR/build/pkg"

# ── 包元信息 ──────────────────────────────────────────────────────────────────
PKG_NAME="cluster"
PKG_VERSION="${VERSION:-1.0.0}"
PKG_MAINTAINER="RyanZ <ryanzzzz@foxmail.com>"
PKG_DESCRIPTION="MQTT 节点管理与游戏控制系统（征服/占领/爆破三模式）"
PKG_URL="https://github.com/RyanZhangK/Cluster"

# ── 安装目标路径 ───────────────────────────────────────────────────────────────
INSTALL_BIN="/usr/bin/$PKG_NAME"
INSTALL_SHARE="/usr/share/$PKG_NAME"
INSTALL_DESKTOP="/usr/share/applications/$PKG_NAME.desktop"

echo "==> [1/4] 清理旧产物"
rm -rf "$DIST_DIR" "$STAGE_DIR" "$PKG_DIR"
mkdir -p "$DIST_DIR" "$STAGE_DIR" "$PKG_DIR"

echo "==> [2/4] Nuitka 编译"
cd "$SRC_DIR"
python -m nuitka \
    --enable-plugin=pyside6 \
    --standalone \
    --include-data-dir=resources/audio=resources/audio \
    --output-dir="$DIST_DIR" \
    --output-filename="$PKG_NAME" \
    --assume-yes-for-downloads \
    main.py

NUITKA_OUT="$DIST_DIR/main.dist"

echo "==> [3/4] 组装 stage 目录"
# 主二进制
install -Dm755 "$NUITKA_OUT/$PKG_NAME" "$STAGE_DIR$INSTALL_BIN"

# 音效资源
install -dm755 "$STAGE_DIR$INSTALL_SHARE/audio"
cp "$NUITKA_OUT/resources/audio/"*.wav "$STAGE_DIR$INSTALL_SHARE/audio/"

# Qt 运行时库（Nuitka standalone 产物中除主二进制外的所有文件）
install -dm755 "$STAGE_DIR$INSTALL_SHARE/lib"
rsync -a --exclude="$PKG_NAME" --exclude="resources/" "$NUITKA_OUT/" "$STAGE_DIR$INSTALL_SHARE/lib/"

# 用 wrapper 脚本替换 /usr/bin/cluster，设置 LD_LIBRARY_PATH
cat > "$STAGE_DIR$INSTALL_BIN" <<'EOF'
#!/bin/sh
SHARE=/usr/share/cluster
exec env LD_LIBRARY_PATH="$SHARE/lib:$LD_LIBRARY_PATH" "$SHARE/lib/cluster" "$@"
EOF
chmod 755 "$STAGE_DIR$INSTALL_BIN"
install -Dm755 "$NUITKA_OUT/$PKG_NAME" "$STAGE_DIR$INSTALL_SHARE/lib/$PKG_NAME"

# .desktop 文件（可选，桌面环境显示图标）
cat > "$STAGE_DIR$INSTALL_DESKTOP" <<EOF
[Desktop Entry]
Name=Cluster
Comment=$PKG_DESCRIPTION
Exec=$PKG_NAME
Icon=$PKG_NAME
Terminal=false
Type=Application
Categories=Utility;
EOF

echo "==> [4/4] fpm 打包"
FPM_COMMON=(
    -s dir
    -C "$STAGE_DIR"
    -n "$PKG_NAME"
    -v "$PKG_VERSION"
    --maintainer "$PKG_MAINTAINER"
    --description "$PKG_DESCRIPTION"
    --url "$PKG_URL"
    --prefix /
    .
)

# ── .deb (apt) ────────────────────────────────────────────────────────────────
fpm "${FPM_COMMON[@]}" \
    -t deb \
    --depends libgl1 \
    --depends libegl1 \
    --depends libasound2 \
    --deb-no-default-config-files \
    -p "$PKG_DIR/${PKG_NAME}_${PKG_VERSION}_amd64.deb"

echo "    生成: $PKG_DIR/${PKG_NAME}_${PKG_VERSION}_amd64.deb"

# ── .pkg.tar.zst (pacman) ─────────────────────────────────────────────────────
fpm "${FPM_COMMON[@]}" \
    -t pacman \
    --depends qt6-base \
    --depends alsa-lib \
    -p "$PKG_DIR/${PKG_NAME}-${PKG_VERSION}-1-x86_64.pkg.tar.zst"

echo "    生成: $PKG_DIR/${PKG_NAME}-${PKG_VERSION}-1-x86_64.pkg.tar.zst"

echo ""
echo "✓ 构建完成，包文件位于 build/pkg/"
ls -lh "$PKG_DIR/"
