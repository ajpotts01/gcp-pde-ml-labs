import glob
import os
import logging
import zipfile

import functions_framework
import google.cloud.logging
from google.cloud import storage, language_v1, bigquery, secretmanager
from google.cloud.language_v1.types import Document


def get_request_data(text: str) -> dict:
    return_value = dict(document=dict(type="PLAIN_TEXT", content=text))

    return return_value


def make_nl_request(text: str) -> language_v1.ClassifyTextResponse:
    nl_client = language_v1.LanguageServiceClient()
    request_content = get_request_data(text)

    response = nl_client.classify_text(request=request_content)

    return response


def classify_text(article: str) -> language_v1.ClassifyTextResponse:
    nl_client: language_v1.LanguageServiceClient = language_v1.LanguageServiceClient()

    response = nl_client.classify_text(
        document=Document(content=article, type_="PLAIN_TEXT")
    )

    return response


def get_data_bucket_name() -> str:
    # This is running as a cloud function, so shouldn't need project ID etc.
    # Secret ID is set up by Terraform infra, and exposed as environment variable.
    bucket_id: str = os.getenv("GCS_BUCKET_ID")

    return bucket_id


def unzip_file(path: str) -> str:
    try:
        logging.info(f"Unzipping {path}")
        with zipfile.ZipFile(path, "r") as file_zip:
            unzip_path = f"/tmp/extracts/{os.path.basename(path)}/"
            file_zip.extractall(path=unzip_path)
            return unzip_path
    except Exception as ex:
        logging.error(ex)


def unzip_bucket_files(storage_client: storage.Client, bucket_name: str) -> list:
    files = storage_client.list_blobs(bucket_or_name=bucket_name)
    logging.info(f"Files listed: {files}")
    extract_paths = []

    for next_file in files:
        logging.info(f"Downloading file: {next_file.name}")
        temp_path = f"/tmp/{next_file.name}"
        next_file.download_to_filename(temp_path)
        extract_path = unzip_file(path=temp_path)
        logging.info(f"Appending: {extract_path}")
        extract_paths.append(extract_path)

    return extract_paths


def compile_nl_responses(extract_paths: str) -> list:
    return_value = []

    logging.info(f"Compiling responses for files in: {extract_paths}")
    # This can probably be improved with some kind of os.walk call(s)

    pattern = "/tmp/extracts/**/*.*"
    file_list = [file for file in glob.glob(pattern, recursive=True)]

    logging.info(f"Final file list: {file_list}")

    for next_file_path in file_list:
        if not (
            zipfile.is_zipfile(next_file_path)
            or "README" in next_file_path
            or os.path.isdir(next_file_path)
        ):
            with open(next_file_path, "r") as next_file:
                text = next_file.read()
                logging.info(f"File: {next_file_path}, text: {text}")
                response = make_nl_request(text=text)

                if len(response.categories) > 0:
                    return_value.append(
                        (
                            str(text),
                            str(response.categories[0].name),
                            str(response.categories[0].confidence),
                        )
                    )

    logging.info("Done compiling responses")
    return return_value


def write_to_bq(rows) -> list:
    bq_client: bigquery.Client = bigquery.Client()

    logging.info("Getting dataset ref")
    dataset_ref = bq_client.dataset("news_classification_dataset")
    dataset = bigquery.Dataset(dataset_ref=dataset_ref)

    logging.info("Getting table ref")
    table_ref = dataset.table("article_data")
    table = bq_client.get_table(table_ref)

    logging.info("Inserting rows")
    errors = bq_client.insert_rows(table=table, rows=rows)

    return errors


def setup_logging():
    log_client = google.cloud.logging.Client()
    log_client.setup_logging()


@functions_framework.http
def run(request):
    bucket_name: str = get_data_bucket_name()

    setup_logging()

    logging.info(f"Bucket name: {bucket_name}")

    gcs_client = storage.Client()

    extract_paths = unzip_bucket_files(
        storage_client=gcs_client, bucket_name=bucket_name
    )
    nl_responses = compile_nl_responses(extract_paths=extract_paths)
    bq_errors = write_to_bq(nl_responses)

    if len(bq_errors) > 0:
        logging.error(bq_errors)

    logging.info("Done")
    return "Done", 200
