FROM python:3.10-slim
RUN mkdir /bot && chmod 777 /bot
WORKDIR /bot
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -qq update && apt -qq install -y git wget pv jq wget python3-dev nano software-properties-common curl
COPY . .
RUN pip3 install -r requirements.txt
CMD ["python3","bot.py"]
