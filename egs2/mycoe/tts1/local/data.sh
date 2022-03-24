#!/usr/bin/env bash

set -e
set -u
set -o pipefail

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}
SECONDS=0

stage=0
stop_stage=2

log "$0 $*"
. utils/parse_options.sh

if [ $# -ne 0 ]; then
    log "Error: No positional arguments are required."
    exit 2
fi

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;
. ./db.sh || exit 1;

if [ -z "download" ]; then
   log "Fill the value of 'download' of db.sh"
   exit 1
fi
db_root=downloads

train_set=tr_no_dev
train_dev=dev
eval_set=eval1

if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
    log "stage 0: local/data_prep.sh"
    local/data_prep.sh "${db_root}"/wavs data/train
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    log "stage 2: utils/subset_data_dir.sh"
    # make evaluation and devlopment sets
    utils/copy_data_dir.sh "data/train" "data/${train_set}"
    utils/subset_data_dir.sh --first "data/train" 5 "data/${train_dev}"
    utils/subset_data_dir.sh --last "data/train" 5 "data/${eval_set}"
fi

log "Successfully finished. [elapsed=${SECONDS}s]"
