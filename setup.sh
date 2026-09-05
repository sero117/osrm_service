#!/bin/sh
# سكريبت إعداد بيانات OSRM لخريطة سوريا — يشتغل مرة وحدة بس قبل أول
# تشغيل لـ docker compose، أو أي وقت بدنا نحدث بيانات الطرق (مثلاً
# طريق جديد انبنى بيبرود). محتاج Docker مثبّت على السيرفر.
set -e

cd "$(dirname "$0")"
mkdir -p data
cd data

echo "⬇️  تحميل بيانات خرائط سوريا من Geofabrik..."
wget -N https://download.geofabrik.de/asia/syria-latest.osm.pbf

echo "⚙️  معالجة البيانات (extract → partition → customize)..."
docker run --rm -v "$(pwd):/data" ghcr.io/project-osrm/osrm-backend \
  osrm-extract -p /opt/car.lua /data/syria-latest.osm.pbf

docker run --rm -v "$(pwd):/data" ghcr.io/project-osrm/osrm-backend \
  osrm-partition /data/syria-latest.osrm

docker run --rm -v "$(pwd):/data" ghcr.io/project-osrm/osrm-backend \
  osrm-customize /data/syria-latest.osrm

echo "✅ خلص التجهيز! هلق منقدر نشغل: docker compose up -d"
