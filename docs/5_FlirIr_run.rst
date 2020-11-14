*********************************************
Running the FlirIr Pipeline for Infrared Data
*********************************************

This pipeline extracts temperature data from image files. This guide provides demo data you can use follow along with and ensure the pipeline is functional. 

Pipeline Overview
=================

FlirIr currently uses 4 different programs for data conversion:

.. list-table::
   :header-rows: 1
   
   * - Program
     - Function
     - Input
     - Output
   * - `cleanmetadata <https://github.com/AgPipeline/moving-transformer-cleanmetadata>`_
     - Cleans gantry generated metadata
     - :code:`metadata.json`
     - :code:`metadata_cleaned.json`
   * - `flir2tif <https://github.com/CosiMichele/Containers/tree/master/po_flir2tif_s10>`_
     - Temperature calibrated transformer that converts bin compressed files to tif 
     - :code:`image.bin`
     - :code:`image.tif`
   * - `flirfieldplot <https://github.com/CosiMichele/Containers/tree/master/flirfieldplot>`_
     - GDAL based transformer that combines all immages into a single orthomosaic
     - Directory of all converted :code:`image.tif`
     - :code:`ortho.tif`
   * - `plotclip_geo <https://github.com/emmanuelgonz/plotclip_shp>`_
     - Clips plots from orthomosaic
     - :code:`coordinatefile.geojson`, :code:`ortho.tif`
     - :code:`clipped_plots.tif`
   * - `stitch_plots <https://github.com/emmanuelgonz/stitch_plots>`_
     - Renames and stitches plots
     - Directory of all :code:`clipped_plots.tif`
     - :code:`stitched_plots.tif`
   * - `po_temp_cv2stats <https://github.com/CosiMichele/Containers/tree/master/po_meantemp_comb>`_ 
     - Extracts temperature using from detected biomass
     - :code:`coordinatefile.geojson`, Directory of all :code:`stitched_plots.tif`
     - :code:`meantemp.csv`

Running the Pipeline 
====================

.. note::
   
   At this point, we assume that the interactive "manager" and "worker" nodes have already been setup and are running, and the pipelines have been cloned from GitHub. 
   If this is not the case, start `here <https://phytooracle.readthedocs.io/en/latest/2_HPC_install.html>`_.

**Retrieve data**

Navigate to your directory containing FlirIr, and download the data from the CyVerse DataStore with iRODS commands and untar:

.. code::

   cd /<personal_folder>/PhytoOracle/FlirIr
   iget -rKVP /iplant/home/shared/terraref/ua-mac/raw_tars/demo_data/Lettuce/FlirIr_demo.tar
   tar -xvf FlirIr_demo.tar

Data from the Gantry can be found within :code:`/iplant/home/shared/terraref/ua-mac/raw_tars/season_10_yr_2020/flirIrCamera/<scan_date>.tar`
   
**Edit scripts**

+ :code:`process_one_set.sh`

  Find your current working directory using the command :code:`pwd`
  Open :code:`process_one_set.sh` and copy the output from :code:`pwd` into line 14. It should look something like this:

  .. code:: 

    HPC_PATH="xdisk/group_folder/personal_folder/PhytoOracle/FlirIr/"

+ :code:`entrypoint_M.sh`

  + In line 3, specify the :code:`<scan_date>` folder you want to process. For our purposes, this will look like:

    .. code:: 

      DATE="FlirIr_demo"

  + In lines 13 and 16, specify the location of CCTools:

    .. code:: 

      /home/<u_num>/<username>/cctools-<version>-x86_64-centos7/bin/jx2json

    and

    .. code:: 

      /home/<u_num>/<username>/cctools-<version>-x86_64-centos7/bin/makeflow

**Run pipeline**

Begin processing using:

.. code::

  ./entrypoint_M.sh

.. note::

   This may return a notice with a "FATAL" error. This happens as the pipeline waits for a connection to DockerHub, which takes some time. Usually, the system will fail quickly if there is an issue.

   If the pipeline fails, check to make sure you have a "/" concluding line 14 of :code:`process_one_set.sh`. This is one of the most common errors and is necessary to connect the program scripts to the HPC.