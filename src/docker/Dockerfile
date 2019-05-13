from azuresdk/azure-cli-python:latest
LABEL maintainer="Quincy.Cheng@CyberArk.com"

WORKDIR /app

COPY ./server.py  ./requirements.txt ./secrets.yml ./*.sh /app/

RUN mkdir -p /usr/local/lib/
COPY ./summon /usr/local/bin/

RUN mkdir -p /usr/local/lib/summon/
COPY ./summon-conjur /usr/local/lib/summon/

RUN pip install -r /app/requirements.txt

ENTRYPOINT ["python"]

RUN touch /var/log/cron.log

RUN echo '*  *  *  *  *    summon /app/cleanup_sp.sh' > /etc/crontabs/root

CMD ["/app/server.py"]
