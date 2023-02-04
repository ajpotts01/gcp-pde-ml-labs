import requests

import functions_framework


def get_request_data() -> dict:
    return_value = dict(
        document=dict(
            type="PLAIN_TEXT",
            content="A Smoky Lobster Salad With a Tapa Twist. This spin on the Spanish pulpo a la gallega skips the octopus, but keeps the sea salt, olive oil, pimentón and boiled potatoes.",
        )
    )

    return return_value


def make_nl_request() -> requests.Response:
    api_url: str = "https://language.googleapis.com/v1/documents:classifyText"
    request_content = get_request_data()

    response = requests.post(url=api_url, json=request_content)

    return response


@functions_framework.http
def run(request):
    response = make_nl_request()

    if response.status_code == 200:
        return_value = response.content
    else:
        return_value = "error"

    return return_value
