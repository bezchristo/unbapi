# UNBAPI (Unstable)

The following tutotial will set up an unofficial banking api service

It makes use of the following services:
* Cloud Functions
* Gateway API
* Taiko
* Nodejs	

To setup the unofficial api follow the tutorial on google cloud shell.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fbezchristo%2Funbapi.git&cloudshell_print=cloud-shell-readme.txt&cloudshell_open_in_editor=main.tf&cloudshell_tutorial=tutorial.md&hl=en_GB&fromcloudshell=true&shellonly=false#id=I0_1588005425124&_gfid=I0_1588005425124&parent=https:%2F%2Fconsole.cloud.google.com)

## Which banks are currently supported?
* Investec - Personal

## How to add more banks
1. Create a folder under `\src\functions` with the Bank's name in the format `{{bank}}Pay`.
2. Add an `index.js` and `package.json` file containing the taiko code to make the payment.
3. Zip both files into a zip file named the same as the folder i.e. `investecPay.zip`.
4. Edit the `\apigateway\openapi.yaml` file and add a new `path` for your bank.
5. Edit the main.tf file and add the folowing:
   * Add a new `resource "google_storage_bucket_object"` for your bank.
   * Add a new `resource "google_cloudfunctions_function"` for your bank.
   * Add a new `resource "google_cloudfunctions_function_iam_member"` for your bank.
6. Create a PR.

Once the PR is merged, run the terraform script to deploy the new bank.

## Issues
If you run into any issues on the tutorial please raise an issue on github.