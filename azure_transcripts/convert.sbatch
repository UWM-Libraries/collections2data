#!/bin/bash
#SBATCH --array=0-13

readarray directories < filenames.txt
readarray output < output.txt
#deepspeech --model deepspeech-0.5.1-models/output_graph.pbmm --alphabet deepspeech-0.5.1-models/alphabet.txt --lm deepspeech-0.5.1-models/lm.binary --trie d
#oeepspeech-0.5.1-models/trie --audio ${directories[${SLURM_ARRAY_TASK_ID}]}


/sharedapps/pkg-*/bin/ffmpeg3 -i ${directories[${SLURM_ARRAY_TASK_ID}]} -map 0:1 -ac 1 -ar 16000 ${output[${SLURM_ARRAY_TASK_ID}]}

