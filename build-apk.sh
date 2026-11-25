#!/bin/bash
# بناء APK لتطبيق فارس والحيوانات (محلي فقط — لا رفع ولا سيرفر).
# توقيع debug الافتراضي؛ لا يوجد مخزن إصدار ولا كلمة سر.
# نفس إعدادات بيئة البناء المستخدمة في تطبيقات شفاء وفارس وفهد:
# تفضيل IPv6 للـ loopback وإعدادات البروكسي من متغيرات بيئة الجهاز
# وقت التشغيل فقط؛ لا توجد أي بيانات اعتماد مكتوبة في هذا الملف.
set -e
cd "$(dirname "$0")"

export HOME=/home/hatch
export JAVA_HOME="$HOME/programs/jdk-17"
export ANDROID_HOME="$HOME/programs/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export GRADLE_USER_HOME="$HOME/programs/gradle-home-fares"
# GRADLE_USER_HOME مستقل عن مشاريع زخم وشفاء وفارس وفهد، حتى لا
# يتعارض بناء هذا التطبيق مع بناء آخر يعمل بالتوازي.

P_AUTH="${https_proxy#*://}"
P_AUTH="${P_AUTH%%@*}"
P_USER="${P_AUTH%%:*}"
P_PASS="${P_AUTH#*:}"
export JDK_JAVA_OPTIONS="-Djava.net.preferIPv6Addresses=true -Djava.net.preferIPv4Stack=false -Djavax.net.ssl.trustStore=$HOME/programs/java-truststore.jks -Djavax.net.ssl.trustStorePassword=changeit -Dhttp.proxyHost=hatch-egress-proxy -Dhttp.proxyPort=3128 -Dhttp.proxyUser=$P_USER -Dhttp.proxyPassword=$P_PASS -Dhttps.proxyHost=hatch-egress-proxy -Dhttps.proxyPort=3128 -Dhttps.proxyUser=$P_USER -Dhttps.proxyPassword=$P_PASS"

"$HOME/flutter/bin/flutter" build apk --debug --no-pub
ls -la build/app/outputs/flutter-apk/app-debug.apk
