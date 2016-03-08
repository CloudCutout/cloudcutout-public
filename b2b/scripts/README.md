
### Read the documentation!
Please read the API documentation (../queue-API.md)!

### Integrating using the scripts

The script will take images from an input directory, submit them to the API, monitor already submitted jobs and move completed jobs to the output directory.
Setup your system to run the script every, say, 10 minutes.

First: Write your API key in the top of the script, where it says `$TOKEN=` or `$token=`. Also update the queue-name, if needed.

###### Unix/Linux/Mac
Use `cloudcutout.sh`

1. make it executable using: chmod +x cloudcutout.sh
2. create input and output dirs for the script using: `mkdir input && mkdir output`
3. place images in the input folder
4. call the script using: `./cloudcutout.sh input output`

###### Windows
Use `cloudcutout.ps1`

1. create input and output dirs for the script using: `mkdir input; mkdir output`
2. place images in the input folder
3. call the script using: `./cloudcutout.ps1 input output`

Minimum requirement for Windows environments are Powershell 3.0.
