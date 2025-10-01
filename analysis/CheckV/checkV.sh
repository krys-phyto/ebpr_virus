# Krys Kibler
# 2025-09-19

# goal - to check quality and obtain sequences


### create checkV environment
source /home/GLBRCORG/kjkibler/miniconda3/etc/profile.d/conda.sh

export PATH=//home/GLBRCORG/kjkibler/miniconda3/bin:$PATH
unset PYTHONPATH

PYTHONPATH=""
PERL5LIB=""

conda create --name checkv python=3.9

conda activate checkv
conda install -c conda-forge -c bioconda checkv=1.0.1
checkv download_database ./


export CHECKVDB=/home/glbrc.org/kjkibler/miniconda3/envs/checkv/database/checkv-db-v1.5


### code

checkv end_to_end <input_file.fna> output_directory -t 16
