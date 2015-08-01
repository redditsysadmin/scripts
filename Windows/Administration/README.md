Example syntax for scripts located in this directory. Please keep this list in alphabetical order.


**CAPI_to_userCertificate.ps1**

  **Example:**

    powershell -file CAPI_to_userCertificate.ps1

  **Description:** The script searches the running user's personal certificate store for certificates with the EKU for "smart card logon". The script then imports the certificate to the users AD user object under the userCertificates attribute. The script has no parameters and should be run as a non-privileged user. You must fill the correct variables prior to running the script.

**getAddRemovePrograms.ps1**

  **Example:**

    powershell -file getAddRemovePrograms.ps1 Firefox

  **Description:** The script searches the registry for installed programs and returns the program registry key(s) as an object.
