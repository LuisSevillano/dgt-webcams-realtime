#!/bin/bash

timestamp=$(date +%s)
base_dir="images"

input_file="camaras.txt"

mkdir -p "$base_dir"

echo "Iniciando descarga de webcams DGT..."

while IFS= read -r line; do
    if [[ $line == \#* ]]; then
        province="${line#\# }"
        province=$(echo "$province" | xargs)
        continue
    fi

    if [[ $line =~ ^([A-Za-z0-9]+)PK([0-9]+(\.[0-9]+)?) ]]; then
        carretera="${BASH_REMATCH[1]}"
        kilometro="${BASH_REMATCH[2]}"
        url_raw="${line#*=}"

        url="${url_raw}?t=${timestamp}"

        kilometro_dir="$base_dir/$province/$carretera/$kilometro"

        mkdir -p "$kilometro_dir"

        final_image="$kilometro_dir/${carretera}_PK${kilometro}_${timestamp}.jpg"

        echo "Descargando: $province - $carretera (PK $kilometro)"

        curl -sL "$url" -o "$final_image" --max-time 10

        if [ ! -s "$final_image" ]; then
            echo "⚠️ Error al descargar $url"
            rm "$final_image"
        fi
    fi
done < "$input_file"

echo "----------------------------------------------------"
echo "Proceso completado. Imágenes listas en carpeta /$base_dir"