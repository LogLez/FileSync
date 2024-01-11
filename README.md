# FileSync

<h2 align="center">
<br>
<img src="LO14-FileSync.png" alt="PSI logo">
<br><br>
 FileSync
<br><br>
A simple Bash program for school Project LO14 
that allows to synchronize directories in the same local machine
<br>
</h2>

<div align="left">

![Bash](https://img.shields.io/badge/Bash-blue)

</div>

---

### What is this application ?

FileSync is a LO14's project that allow to synchronize 2 directories by coping files, very similar to the rsync command from
linux.

_This is a project for LO14 course !_

### 1. How do the application work ?

Overall, this program allows you to synchronize 2 distinct directories specified in parameters. It supports several scenarios and allows you to arrive at an identical tree scene of the 2 directories.
This is particularly possible with the help of a journal, a document where the files and their data will be stored for each synchronization.

Here you can see the structure of the diary:

```markdown
source=G
destination=B
LastEdit=1704152348
document.docx,607b0ff9c01356237d9d75af7f888c81784d7f4830a582931091dcd7106ac6a1,644,1703502912

source=T
destination=G
LastEdit=1704194418
document.docx,607b0ff9c01356237d9d75af7f888c81784d7f4830a582931091dcd7106ac6a1,644,1703502912

source=A
destination=B
LastEdit=1704894493
document.docx,607b0ff9c01356237d9d75af7f888c81784d7f4830a582931091dcd7106ac6a1,644,1703502912
rocket.md,37b49dafba9e64a23237ee9fa7a35f934d6541b6fc3b17af385af6c7d5422e7a,644,1702234700
test/ppt.pptx,e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855,644,1704837065
```

Each block corresponds to a synchronization with the source directory, the target directory, the last modification date, and all the files common to both directories.

> [!WARNING]
>*It is important to understand that the directories are called 'source' and 'target' to have a better comprehension. This does not mean that there is a SOURCE and a TARGET directories, we can inverse them, the result will be the same. we could called them A directory and B directory.*

Here some commands of the program that you can find just below :

- help : shows all commands and its description
- init : Init the synchronization between 2 directories ./sync init '<Directory A>' '<Directory B>'
- start : Start the synchronization between 2 directories. If it's the first time, the init will be created ./sync start '<Directory A>' '<Directory B>'
- remove : Remove the synchronization between 2 directories from the file will be created ./sync remove '<Directory A>' '<Directory B>'
- infos : Get informations from the diary wtih specified options ./sync infos [ -options ]
  Options :
  -s --> specified the source/dest directory
  -t --> specified the source/dest directory
  -b --> specified the start date in TimeUnix
  -e --> specified the end date in TimeUnix

  Examples:
  ```markdown
  ./sync.sh infos -s A --> Get all synchronizations with A directory inclued.
  ./sync.sh infos -s A -t B -s 1704196218 --> Get all synchronizations with A and B directories inclued and with a lastEdit equals or newer than 1704196218
  ./sync.sh infos -s A -t B -s 1704196218 -e 1704196250 --> Get all synchronizations with A and B directories inclued and with a lastEdit equals or newer than 1704196218 and equals or lower than 1704196250
  ./sync.sh infos -s A -t B -s 1704196218 -e 1704196250 --> Get all synchronizations with A and B directories inclued and with a lastEdit equals or newer than 1704196218 and equals or lower than 1704196250
  ```

### 2. Installation of the dependencies

- No libraries needed. There is only need to support Bash programming language


> [!WARNING]
>*Depending on your environment, the variable $DIARY has to be set. This variable must point to a file called diary.synchro. Make sure to start your script using 'source' to export the DIARY variable -- > source ./sync.sh         
Otherwise, create your environment variable manually.*


### 3. How can we use this application ?

- You just have to execute the script and following depending on what command you want to use.

```shell
./sync.sh
```

It is very simple !  Don't worry :)


**Versions history:**

|      Version       | Date           | 
|--------------------|----------------|
| **1.0.0**          | 10 / 01 / 2024 | 

-----