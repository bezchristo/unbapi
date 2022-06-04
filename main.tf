# Set providers (Need to use beta for Gateway)
provider "google-beta" {
  project = var.project
  version = "~> 3.48.0"
}

provider "google" {
  project = var.project
  version = "~> 3.48.0"
}


# Enable the required API's
resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = var.project
  service = each.key
  
  disable_dependent_services = true
}


# Create source code bucket
resource "google_storage_bucket" "bucket" {
  name = "unbapi_source_code"
}


# Investec
resource "google_storage_bucket_object" "investecPay_code" {
  name   = "investecPay.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./src/functions/investecPay/"
}

resource "google_cloudfunctions_function" "investecPay_function" {
  name        = "investecPay"
  description = "Makes Investec once-off payment"
  runtime     = "nodejs12"

  available_memory_mb   = 2048
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.investecPay_code.name
  timeout               = 60
  entry_point           = "investecPay"
  trigger_http          = true
  project               = var.project
  region                = "us-central1"
}


# Create the Gateway
resource "google_api_gateway_api" "api_gw" {
  provider = google-beta
  api_id = "api-gw"
  display_name = "UNBAPI API"
}

resource "google_api_gateway_api_config" "api_gw" {
  provider = google-beta
  api = google_api_gateway_api.api_gw.api_id
  api_config_id = "config"
  display_name = "UNBAPI API Config"

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = filebase64("./src/apigateway/openapi.yaml")
    }
  }

  gateway_config {
    backend_config {
	  google_service_account = "${var.project}@appspot.gserviceaccount.com"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "api_gw" {
  provider = google-beta
  api_config = google_api_gateway_api_config.api_gw.id
  gateway_id = "api-gw"
  region     = "us-central1"
  display_name = "UNBAPI Gateway"
}


# IAM entry for a service account to invoke the function
resource "google_cloudfunctions_function_iam_member" "investec_invoker" {
  project        = google_cloudfunctions_function.investecPay_function.project
  region         = google_cloudfunctions_function.investecPay_function.region
  cloud_function = google_cloudfunctions_function.investecPay_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${var.project}@appspot.gserviceaccount.com"
}
