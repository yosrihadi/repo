#!/bin/bash

# تأكد من وجود مجلد debs
if [ ! -d "debs" ]; then
  echo "not found debs"
  exit 1
fi

echo "ceate Packages..."
# استخراج بيانات الحزم
dpkg-scanpackages -m ./debs > Packages

echo "make for Cydia و Sileo و Zebra..."
bzip2 -c9 Packages > Packages.bz2
xz -c9 Packages > Packages.xz
zstd -c19 Packages > Packages.zst

echo "create  Release..."
# بناء ملف Release الأساسي
cat <<EOF > Release
Origin: YH-Pal Repo
Label: YH-Pal Repo
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm iphoneos-arm64
Components: main
Description: مستودع أدواتي الخاصة
Icon: https://raw.githubusercontent.com/yosrihadi/repo/refs/heads/main/CydiaIcon.png

EOF

# حساب التشفير والحجم للملفات وإضافتها لملف Release (مهم جداً لـ Sileo)
echo "MD5Sum:" >> Release
for file in Packages Packages.bz2 Packages.xz Packages.zst; do
    if [ -f "$file" ]; then
        echo " $(md5sum $file | cut -d' ' -f1) $(stat -c%s $file) $file" >> Release
    fi
done

echo "SHA1:" >> Release
for file in Packages Packages.bz2 Packages.xz Packages.zst; do
    if [ -f "$file" ]; then
        echo " $(sha1sum $file | cut -d' ' -f1) $(stat -c%s $file) $file" >> Release
    fi
done

echo "SHA256:" >> Release
for file in Packages Packages.bz2 Packages.xz Packages.zst; do
    if [ -f "$file" ]; then
        echo " $(sha256sum $file | cut -d' ' -f1) $(stat -c%s $file) $file" >> Release
    fi
done

echo " make Sileo! ok"