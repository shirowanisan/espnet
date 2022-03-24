#!/usr/bin/env bash

db=$1
data_dir=$2

# check arguments
if [ $# != 2 ]; then
    echo "Usage: $0 <corpus_dir> <data_dir>"
    exit 1
fi

set -euo pipefail

# check directory existence
[ ! -e "${data_dir}" ] && mkdir -p "${data_dir}"

# set filenames
scp=${data_dir}/wav.scp
utt2spk=${data_dir}/utt2spk
spk2utt=${data_dir}/spk2utt
text=${data_dir}/text

# check file existence
[ -e "${scp}" ] && rm "${scp}"
[ -e "${utt2spk}" ] && rm "${utt2spk}"
[ -e "${text}" ] && rm "${text}"

find ${db}/ -follow -name "*.wav" | sort | while read -r filename; do
    id=$(basename ${filename} | sed -e "s/\.[^\.]*$//g")
    echo "${id} ${filename}" >> ${scp}
    echo "${id} wavs" >> ${utt2spk}
done
utils/utt2spk_to_spk2utt.pl "${utt2spk}" > "${spk2utt}"
echo "finished making wav.scp, utt2spk, spk2utt."

# make text
find downloads -name "transcripts_utf8.txt" | sort | while read -r filename; do
    tr ':' ' ' < "${filename}" | sort >> "${text}"
done
echo "finished making text."

echo "Successfully finished data preparation."
