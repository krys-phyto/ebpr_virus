# Krys Kibler
# 2025-09-24


# Goal: secret mission to bin ebpr viral contigs id'ed with VIBRANT

# https://github.com/AnantharamanLab/vRhyme
### Install vRhyme

git clone https://github.com/AnantharamanLab/vRhyme
cd vRhyme
gunzip vRhyme/models/vRhyme_machine_model_ET.sav.gz

conda create -c bioconda -n vRhyme python=3.6 networkx pandas numpy numba scikit-learn pysam samtools mash mummer mmseqs2 prodigal bowtie2 bwa
conda activate vRhyme

pip install .

test_vRhyme.py # All Python, Program, and Machine Learning Models success
