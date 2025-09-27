#!/bin/bash

echo "Adding custom packages..."

# {{ Add amneziawg
echo "Adding amneziawg..."
(cd friendlywrt/package && {
    [ -d amneziawg-openwrt ] && rm -rf amneziawg-openwrt
    git clone https://github.com/amnezia-vpn/amneziawg-openwrt.git --depth 1
    
    # Проверяем, что репозиторий успешно склонирован
    if [ ! -d amneziawg-openwrt ]; then
        echo "ERROR: Failed to clone amneziawg-openwrt"
        exit 1
    fi
})

cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_kmod-amneziawg=y
CONFIG_PACKAGE_luci-proto-amneziawg=y
CONFIG_PACKAGE_amneziawg-tools=y
EOL
# }}

# {{ Add passwall
echo "Adding passwall..."
(cd friendlywrt/package && {
    [ -d openwrt-passwall ] && rm -rf openwrt-passwall
    git clone https://github.com/xiaorouji/openwrt-passwall.git --depth 1
    
    [ -d openwrt-passwall-packages ] && rm -rf openwrt-passwall-packages  
    git clone https://github.com/xiaorouji/openwrt-passwall-packages.git --depth 1
    
    # Проверяем, что репозитории успешно склонированы
    if [ ! -d openwrt-passwall ] || [ ! -d openwrt-passwall-packages ]; then
        echo "ERROR: Failed to clone passwall repositories"
        exit 1
    fi
})

# Добавляем конфигурацию passwall
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y
CONFIG_PACKAGE_chinadns-ng=y
CONFIG_PACKAGE_dns2socks=y
CONFIG_PACKAGE_geoview=y
CONFIG_PACKAGE_hysteria=y
CONFIG_PACKAGE_ipt2socks=y
CONFIG_PACKAGE_microsocks=y
CONFIG_PACKAGE_naiveproxy=y
CONFIG_PACKAGE_shadow-tls=y
CONFIG_PACKAGE_shadowsocks-libev=y
CONFIG_PACKAGE_shadowsocksr-libev=y
CONFIG_PACKAGE_simple-obfs=y
CONFIG_PACKAGE_sing-box=y
CONFIG_PACKAGE_tcping=y
CONFIG_PACKAGE_trojan-plus=y
CONFIG_PACKAGE_tuic-client=y
CONFIG_PACKAGE_v2ray-plugin=y
CONFIG_PACKAGE_xray-core=y
CONFIG_PACKAGE_xray-plugin=y
EOL
# }}

# {{ Add luci-app-diskman
echo "Adding diskman..."
(cd friendlywrt && {
    mkdir -p package/luci-app-diskman
    wget -t 3 -T 30 https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O package/luci-app-diskman/Makefile
    
    if [ ! -f package/luci-app-diskman/Makefile ]; then
        echo "ERROR: Failed to download diskman Makefile"
        exit 1
    fi
})

cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_smartmontools=y
EOL
# }}

# {{ Add luci-theme-argon
echo "Adding argon theme..."
(cd friendlywrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
    
    if [ ! -d luci-theme-argon ]; then
        echo "ERROR: Failed to clone luci-theme-argon"
        exit 1
    fi
})

echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi

# Модификация setup.sh для темы
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

echo "Custom packages added successfully!"

# Проверяем, что все пакеты на месте
echo "Verifying packages..."
[ -d friendlywrt/package/amneziawg-openwrt ] && echo "✓ amneziawg-openwrt"
[ -d friendlywrt/package/openwrt-passwall ] && echo "✓ openwrt-passwall" 
[ -d friendlywrt/package/openwrt-passwall-packages ] && echo "✓ openwrt-passwall-packages"
[ -d friendlywrt/package/luci-app-diskman ] && echo "✓ luci-app-diskman"
[ -d friendlywrt/package/luci-theme-argon ] && echo "✓ luci-theme-argon"

echo "Package verification complete!"
