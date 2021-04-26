resource "google_storage_bucket" "bucket" {
  name = "century_source_code"
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


