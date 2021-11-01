This directory contains three primary collections of repeatable code:

1.  azure_transcripts
 - Python script submitted through Slurm to send audio files to Azure Cognitive Services Speech to Text service ( https://azure.microsoft.com/en-us/services/cognitive-services/speech-to-text/#features ).      
   - Code includes Python streaming ( large audio files must be streamed ) and disabled profanity checks. 
2. rshiny_dashboard:
- RShiny dashboard that provides:
  - Content warning click through
  - Corpus explorer tool ( https://kgjerde.github.io/corporaexplorer/ )
  - Variable pre-trained LDA topic models
    - LDA topic visualization via LDAvis ( https://github.com/cpsievert/LDAvis )
    - Association of objects with topics
3. rshiny_prep_and_demo
 - prepare_conda_explorer.R
   - Merges contents of transcripts folder and metadata .xls files
   - Generates updated corpus file
 - batch_topic_modeling.R
   - Generates pre-trained LDA topic models and object to topic associations in a loop
 - topic_modeling.R
   - Example topic model analysis of transcripts
 - corpora_explorer_demo
   - Example corporaexplorer demo used in 1.6.21 demo with instructors
4. contentwarning / corporaexplorer
 - Two simple web apps that provide a content warning wrapper prior to accessing a sipmlified CorporaExplorer user interface to our corpus.
