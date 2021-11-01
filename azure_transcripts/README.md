1. azure_transcript.py
 - Python script that accepts an input audio file
 - Sends to Azure Speech to Text services via streaming ( https://github.com/Azure-Samples/cognitive-services-speech-sdk/blob/master/samples/python/console/speech_sample.py Line 257
 - Disables Profanity filter ( https://docs.microsoft.com/en-us/dotnet/api/microsoft.cognitiveservices.speech.speechconfig.setprofanity?view=azure-dotnet )
   - Profanity filter is critical, as vocabulary will regularly be flagged inappropriately
    

2. azure_transcript.sbatch
 - Approach to leverage HPC scheduler to analyize audio files in parallel through a cluster scheduler. Reads array of file names from audio-files.txt and submits as batch job.

3. convert.sbatch
 - Extracts usable resulting transcript from Azure output to save as plaintext files based on transcript_names.txt

4. environment.yml
 - Conda yaml file to recreate Azure python dependencies. 
