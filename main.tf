provider "google-beta" {
  project = var.project
  version = "~> 3.48.0"
}

provider "google" {
  project = var.project
  version = "~> 3.65"
}

resource "google_storage_bucket" "bucket" {
  name = "unbapi_source_code"
}

resource "google_storage_bucket_object" "investecPay_code" {
  name   = "investecPay.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./src/functions/investecPay/investecPay.zip"
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

resource "google_api_gateway_api" "api_gw" {
  provider = google-beta
  api_id = "api-gw"
}

resource "google_api_gateway_api_config" "api_gw" {
  provider = google-beta
  api = google_api_gateway_api.api_gw.api_id
  api_config_id = "config"

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = filebase64("./src/apigateway/openapi.yaml")
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
}

# IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "publish_invoker" {
  project        = google_cloudfunctions_function.investecPay_function.project
  region         = google_cloudfunctions_function.investecPay_function.region
  cloud_function = google_cloudfunctions_function.investecPay_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${var.project}@appspot.gserviceaccount.com"
}

# IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "token_invoker" {
  project        = google_cloudfunctions_function.investecPay_function.project
  region         = google_cloudfunctions_function.investecPay_function.region
  cloud_function = google_cloudfunctions_function.investecPay_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}


