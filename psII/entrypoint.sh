#!/bin/bash

python3 gen_files_list.py 2020-07-28__12-46-35-793 RAW_DATA_PATH _rawData0042.bin > raw_data_files.json
python3 gen_bundles_list.py raw_data_files.json bundle_list.json 1
mkdir -p bundle/
python3 split_bundle_list.py bundle_list.json bundle/
/home/u31/emmanuelgonzalez/cctools-7.1.6-x86_64-centos7/bin/jx2json main_wf_phase1.jx -a bundle_list.json > main_workflow_phase1.json


# -a advertise to catalog server
/home/u31/emmanuelgonzalez/cctools-7.1.6-x86_64-centos7/bin/makeflow -r 1000 -T wq --json main_workflow_phase1.json -a -M phyto_oracle-atmo -p 0 -dall -o dall.log --disable-cache $@

