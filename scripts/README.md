# scripts

Denne mappe indeholder de scripts der bliver kørt i hhv. Linux og Windows, samt .xml filer der bliver brugt til at sætte Windows op.

## Oversigt

| File                     | Description                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------|
| **autounattend.xml**     | Svarfil til Windows installation. Automatiserer partitionering, setup osv.                       |
| **download.sh**          | Bash-script downloader og skriver Windows-imaged til disken.                                     |
| **FirstLogon.ps1**       | PowerShell-script der bliver kørt ved første logind.                |
| **firstrun.ps1**         | PowerShell-script som samler info. (serial, UUID, IP, MAC, etc.) og sender det til Flask appen.      |
| **format.sh**            | Bash-script der partitionerer og formaterer disken til Windows-installationen.  |
| **run_os-deploy_script.sh** | Henter start.sh med curl                        |
| **specialize.xml**       | XML-svarfil der bliver brugt efter sysprep, når OS-deploy er færdig og Windows starter for første gang |
| **start.sh**             | Første Bash-script der bliver kørt. Finder den største disk og henter næste script. |

