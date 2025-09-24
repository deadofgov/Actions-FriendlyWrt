#!/bin/bash

# {{ Add luci-app-diskman
(cd friendlywrt && {
    mkdir -p package/luci-app-diskman
    wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O package/luci-app-diskman/Makefile
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_smartmontools=y
EOL
# }}

# {{ Add amneziawg-openwrt
(cd friendlywrt/package && {
    [ -d amneziawg-openwrt ] && rm -rf amneziawg-openwrt
    git clone https://github.com/amnezia-vpn/amneziawg-openwrt.git --depth 1
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_amneziawg-tools=y
CONFIG_PACKAGE_kmod-amneziawg=y
CONFIG_PACKAGE_luci-proto-amneziawg=y
EOL
# }}

# {{ Add passwall2 (with deps)
(cd friendlywrt/package && {
    [ -d openwrt-passwall2 ] && rm -rf openwrt-passwall2
    git clone https://github.com/xiaorouji/openwrt-passwall2.git --depth 1
})

# Passwall2 dependencies (base + plugins)
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-passwall2=y
CONFIG_PACKAGE_luci-i18n-passwall2-zh-cn=y
CONFIG_PACKAGE_ipt2socks=y
CONFIG_PACKAGE_microsocks=y
CONFIG_PACKAGE_pdnsd-alt=y
CONFIG_PACKAGE_simple-obfs=y
CONFIG_PACKAGE_trojan-plus=y
CONFIG_PACKAGE_v2ray-core=y
CONFIG_PACKAGE_v2ray-geoip=y
CONFIG_PACKAGE_v2ray-geosite=y
CONFIG_PACKAGE_v2ray-plugin=y
CONFIG_PACKAGE_xray-core=y
CONFIG_PACKAGE_xray-plugin=y
CONFIG_PACKAGE_naiveproxy=y
CONFIG_PACKAGE_shadowsocks-libev-ss-local=y
CONFIG_PACKAGE_shadowsocks-libev-ss-redir=y
CONFIG_PACKAGE_shadowsocks-libev-ss-server=y
CONFIG_PACKAGE_shadowsocks-libev-ss-tunnel=y
CONFIG_PACKAGE_shadowsocks-rust-sslocal=y
CONFIG_PACKAGE_shadowsocks-rust-ssserver=y
CONFIG_PACKAGE_shadowsocks-rust-ssredir=y
CONFIG_PACKAGE_shadowsocks-rust-sstunnel=y
EOL
# }}

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
cat > /tmp/appendtext.txt <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e '/boardname=/r /tmp/appendtext.txt' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}
