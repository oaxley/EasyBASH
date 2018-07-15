### EasyBASH profile

EasyBASH is a custom BASH profile that is easy to customized and maintained.

The configuration files are store in '**.bashrc.d**' directory and must have the extension '.run' to be loaded.  
Any other extension and the file will be ignored.

The directory architecture is as follows:   
- **alias** : aliases definition  
- **completion** : tab completions  
- **environment** : environment variables  
- **functions** : custom functions  
- **path** : PATH, LD_LIBRARY_PATH, ...   
- **extra** : 3rd parties shell scripts  

The loader will try to run the files that matches one of the following rules:  
1. a file with the hostname (file.*mercury*.run)  
2. a file with the system (file.*linux*.run)  
3. if 1 and 2 are unsuccessful, any file (file.run)  


For bash scripts that needs to load the environment, a special variable must be set: **NON_INTERACTIVE**  
If the value is set to "**yes**" then only the following parts of the bash profile are loaded:  
- the functions  
- the environment variables  
- the paths  

If the value is "**no**" then the full environment is loaded, like a normal interactive shell.

The files are loaded in their alphabetical order.
