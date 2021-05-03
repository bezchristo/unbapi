# Yo welcome to the UNBAPI tutorial

<walkthrough-tutorial-duration duration=5></walkthrough-tutorial-duration>

## Setup Project

### Create Project

<walkthrough-project-billing-setup></walkthrough-project-billing-setup>

### Set project as default

``` bash
gcloud config set project {{project-id}}
```

### Enable Api's

```` bash
gcloud services enable apigateway.googleapis.com
````

```` bash
gcloud services enable servicemanagement.googleapis.com
````

```` bash
gcloud services enable servicecontrol.googleapis.com
````

```` bash
gcloud services enable cloudbuild.googleapis.com
````

```` bash
gcloud services enable cloudfunctions.googleapis.com
````

### Apply terraform file and variables

``` bash
terraform init
```

``` bash
terraform apply -var project="{{project-id}}"
```
