FROM registry.hub.docker.com/nvidia/cuda:11.8.0-runtime-ubuntu22.04

RUN apt-get update
RUN apt install -y wget git python3 python3-pip python3-virtualenv bash

RUN useradd alpaca
RUN mkdir /app
RUN mkdir /home/alpaca
RUN chown -R alpaca:alpaca /home/alpaca
RUN chown alpaca:alpaca /app

USER alpaca
WORKDIR /app

RUN git clone https://github.com/deep-diver/Alpaca-LoRA-Serve .
RUN virtualenv venv
RUN . venv/bin/activate && pip install -r requirements.txt

ENV BASE_URL='decapoda-research/llama-7b-hf'
ENV FINETUNED_CKPT_URL='tloen/alpaca-lora-7b'

# Disgusting fix for cuda libs not working right
WORKDIR /app/venv/lib/python3.10/site-packages/bitsandbytes
RUN cp libbitsandbytes_cuda118.so libbitsandbytes_cpu.so

WORKDIR /app

CMD . venv/bin/activate && exec python app.py --base_url $BASE_URL --ft_ckpt_url $FINETUNED_CKPT_URL --port 6006