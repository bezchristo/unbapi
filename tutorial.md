# Yo welcome to the UNBAPI tutorial

<walkthrough-tutorial-duration duration=5></walkthrough-tutorial-duration>

## Setup Project

### Create Project
<walkthrough-project-setup billing=true></walkthrough-project-setup>

### Set project as default

``` bash
gcloud config set project {{project-id}}
```

### Apply terraform file and variables

``` bash
terraform init
```

``` bash
terraform apply -var project="{{project-id}}"
```
