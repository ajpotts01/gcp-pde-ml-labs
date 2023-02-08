# Simple Python Cloud Functions Using GCP NL/ML Functionality
NL/ML capabilities demonstrated in Python from the official Google Professional Data Engineer certification material.

These are actually possible to do directly through Qwiklabs/Cloud Skills Boost, but the labs boil down to getting you to just run mostly pre-written code. I'm taking a different approach in reading the lab material, and writing it myself. Maybe adding CI/CD bells and whistles. In this case, I have made the code from the labs into Cloud Functions, with Cloud Scheduler instances to trigger them, all managed by Terraform. This is far beyond the scope of the original lab, but was a useful exercise nonetheless.

Original lab is [here on Cloud Skills Boost](https://www.cloudskillsboost.google/course_sessions/2358822/labs/344823). The functions use

The function code can be found in `/functions`:
- `basic-classify`, which sends text to the GCP Natural Language API and returns the classification result
- `bigquery-classify`, which goes further to classify a larger set of text and output to BigQuery.

Steps to set up:
1. Clone the repo
2. Create and activate a Python virtual environment + run `pip install -r requirements.txt` from `/functions` if planning to run locally
3. Install [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform) - I used 1.3.5

If running locally:
1. Run `python basic_classify.py` from `functions/basic-classify/src`, or `python bigquery-classify/src/bigquery_classify.py`

Note that `bigquery_classify.py` will require a GCP account with BigQuery dataset created even if running locally.

If running on Google Cloud Platform
1. Set up a Google Cloud Platform account
2. Install the Google Cloud SDK
3. Create a service account - and either use the key file as `GOOGLE_APPLICATION_CREDENTIALS` or set up your own account to impersonate that service account
    - If impersonating, set your application default credentials by running `gcloud auth application-default login`
4. Create a bucket to hold the terraform state, and edit `backend.tf` to correspond to that bucket
5. Create a `terraform.tfvars` file in `infrastructure`, with the following values:
    - `gcp_project`: Your GCP project ID from step 1
    - `gcp_region`: Your desired region
6. Run `terraform init`/`terraform apply`
7. This should set up everything to run - and you should be able to trigger your Cloud Schedulers manually if you want to observe the functions running.

# Known Issues
1. The Terraform code specifies a managed bucket for the state but it isn't dynamically linked 
2. Service APIs need to be set up properly (they're in `terraform.tfvars` at the moment, which is in `.gitignore`). Proper setup of these individually with proper dependencies is on the to-do list