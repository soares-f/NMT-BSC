#!/bin/bash

#===============================================================================
#
#          FILE:  translate_bpe.sh
#
#         USAGE:  ./translate_bpe.sh options
#
#   DESCRIPTION: Bash script to perform the translation of a source file in any
#				 of the source and target languages: EN, PT and ES.
#
#       OPTIONS:  
#				-s for source language: en, es or pt
#				-t for target languag: en, es or pt
#				-f complete path too file to translate
#				-b complete path to BPE model
#				-o complete path to output file
#				-g number of GPUs e.g. '1' or '1 2'
#				-m complete path to OpenNMT translation model
#				-n complete path to OpenNMT source folder
#
#  REQUIREMENTS:  OpenNMT with Luajit http://opennmt.net
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Felipe Soares, soarescmsa@gmail.com
#       COMPANY:  Barcelona Supercomputing Center (BSC)
#       VERSION:  1.0
#       CREATED:  10/16/2018
#      REVISION:  ---
#===============================================================================

src_lang=''
tgt_lang=''
file_to_translate=''
bpe_path=''
output_path=''
gpu_id='1'
model_path=''
onmt_path=''



print_usage() {
  echo "Usage: 
  	-s for source language: en, es or pt
	-t for target languag: en, es or pt
	-f complete path too file to translate
	-b complete path to BPE model
	-o complete path to output file
	-g number of GPUs e.g. '1' or '1 2'
	-m complete path to OpenNMT translation model
	-n complete path to OpenNMT source folder" ;
}

while getopts ':s:t:f:b:o:g:m:n' flag; do
  case "${flag}" in
    s) src_lang;;
    t) tgt_lang;;
    f) file_to_translate;;
    b) bpe_path;;
    o) output_path;;
    g) gpu_id;;
    m) model_path;;
	n) onmt_path;;
    *) print_usage
       exit 1 ;;
  esac
done


# Change directory to OpenNMT
cd ${onmt_path}


# Tokenize
if th tools/tokenize.lua -joiner_annotate -bpe_model ${bpe_path} < ${file_to_translate} > ${file_to_translate}.tok ; then
    echo "Tokenization completed"
else
    echo "Tokenization failed"
	exit
fi

# Add translation direction tokens

if perl -i.bak -pe "s//__opt_src_${src} __opt_tgt_${tgt} /" ${file_to_translate}.tok ; then
	echo "Translation tokens added correctly"
	rm ${file_to_translate}.tok.bak # remove backup file
else
	echo "Error when adding translation tokens" 
	exit
fi

# Perform the translation
th translate.lua -model ${model_path} -gpuid ${gpu_uid} -src ${file_to_translate}.tok -replace_unk true -detokenize_output true -output ${output_path} -disable_logs