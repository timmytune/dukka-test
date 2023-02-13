from rest_framework.views import exception_handler

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        if response.status_code == 500:
            response.data = {"code": 500, "message": "Internal server error"}
        if response.status_code == 404:
            response.data = {"code": 404, "message": "The requested resource was not found on this server"}
    return response