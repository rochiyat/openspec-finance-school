#!/bin/sh
# Siapkan bucket dan akun akses per aplikasi di MinIO. Aman dijalankan berulang.
# Tiap aplikasi hanya bisa membaca/menulis bucket miliknya sendiri; semua bucket private.
#
# Variabel per aplikasi (kosongkan untuk melewati aplikasi itu):
#   <APP>_S3_ACCESS_KEY, <APP>_S3_SECRET_KEY   APP = FTD | KSS | IQROLIFE
# Nama bucket: <app>, misalnya ftd, kss, iqrolife.
set -eu

mc alias set local http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" >/dev/null

for app in ftd kss iqrolife; do
  APP=$(echo "$app" | tr '[:lower:]' '[:upper:]')
  eval "access=\${${APP}_S3_ACCESS_KEY:-}"
  eval "secret=\${${APP}_S3_SECRET_KEY:-}"
  if [ -z "$access" ] || [ -z "$secret" ]; then
    echo "[minio-init] $app: ${APP}_S3_ACCESS_KEY/SECRET_KEY kosong, dilewati"
    continue
  fi

  mc mb --ignore-existing "local/$app"
  mc anonymous set none "local/$app" >/dev/null

  policy="/tmp/$app-rw.json"
  cat > "$policy" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": ["s3:GetBucketLocation", "s3:ListBucket"], "Resource": ["arn:aws:s3:::$app"] },
    { "Effect": "Allow", "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"], "Resource": ["arn:aws:s3:::$app/*"] }
  ]
}
EOF
  mc admin policy create local "$app-rw" "$policy" >/dev/null
  mc admin user add local "$access" "$secret" >/dev/null
  mc admin policy attach local "$app-rw" --user "$access" >/dev/null 2>&1 || true
  echo "[minio-init] $app: bucket dan akses siap"
done
