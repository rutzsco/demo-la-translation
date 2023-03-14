import logging

import azure.functions as func
import os
from azure.storage.blob import ContainerClient
import shutil
import json
import tempfile
import ffmpeg


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    filename =  req.get_json()['filename']

    storage_account_name = os.getenv('STORAGE_ACCOUNT_NAME', 'ecolabtranslationstorage')
    storage_account_key = os.getenv('STORAGE_ACCOUNT_KEY', 'YOUR-KEY')
    storage_account_container = os.getenv('STORAGE_ACCOUNT_CONTAINER', 'audioupload')

    container_client = ContainerClient(f'https://{storage_account_name}.blob.core.windows.net/', storage_account_container, credential=storage_account_key)
    blob_client = container_client.get_blob_client(filename)

    tempdir = tempfile.gettempdir()
    with open(f'{tempdir}/{filename}', 'wb') as file:
        file.write(blob_client.download_blob().readall())

    tempdir = tempfile.gettempdir()
    source_file_location = os.path.join(tempdir, filename)
    updated_filename = filename.replace('mp3', 'WAV').replace('MP3', 'WAV')
    output_file_location = os.path.join(tempdir, updated_filename)

    try:
        os.remove(output_file_location)
    except Exception:
        pass

    with open(source_file_location, 'wb') as file:
        file.write(blob_client.download_blob().readall())
        
    ffmpeg.input(source_file_location).output(output_file_location).run()

    new_blob_client = container_client.get_blob_client(updated_filename)
    data = None
    with open(output_file_location, 'rb') as file:
        data = file.read()
        
    new_blob_client.upload_blob(data, overwrite=True)
    return func.HttpResponse(new_blob_client.blob_name)
