# صورة OSRM جاهزة لسوريا — البيانات بتتحمّل وتتعالج (extract →
# partition → customize) وقت الـ build نفسه وبتنخبز جوا الصورة.
# ما في داعي لأي سكريبت يدوي عالسيرفر — Dokploy بيبني وينشر تلقائياً.
FROM ghcr.io/project-osrm/osrm-backend:latest

WORKDIR /data

# wget لتحميل بيانات الخريطة من Geofabrik
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget \
    && rm -rf /var/lib/apt/lists/*

# تحميل بيانات خرائط سوريا
RUN wget -O syria-latest.osm.pbf https://download.geofabrik.de/asia/syria-latest.osm.pbf

# معالجة البيانات: extract → partition → customize (خوارزمية MLD)
RUN osrm-extract -p /opt/car.lua syria-latest.osm.pbf \
    && osrm-partition syria-latest.osrm \
    && osrm-customize syria-latest.osrm \
    && rm -f syria-latest.osm.pbf

EXPOSE 5000

CMD ["osrm-routed", "--algorithm", "mld", "/data/syria-latest.osrm"]
