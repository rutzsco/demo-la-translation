# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/python:3.0-python3.7-appservice
FROM mcr.microsoft.com/azure-functions/python:4-python3.7

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true 
    
COPY requirements.txt /
RUN pip install -r /requirements.txt

RUN apt-get update --allow-releaseinfo-change
RUN apt-get install libssl1.1 libasound2 -y
RUN apt-get install ffmpeg -y

COPY . /home/site/wwwroot