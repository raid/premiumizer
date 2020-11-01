FROM python:3.7-alpine as base
FROM base as builder

RUN mkdir /install
WORKDIR /install
COPY requirements.txt ./premiumizer /install/

RUN apk add --update --no-cache libffi-dev openssl-dev python3-dev py3-pip build-base
RUN pip install --prefix /install -r requirements.txt

FROM base

RUN apk add --update --no-cache su-exec shadow \
	&& addgroup -S -g 6006 premiumizer \
	&& adduser -S -D -u 6006 -G premiumizer -s /bin/sh premiumizer

COPY --from=builder /install /usr/local
COPY premiumizer /app

WORKDIR /app
VOLUME /conf
EXPOSE 5000

ENTRYPOINT ["/bin/sh","/app/docker-entrypoint.sh"]
CMD ["/usr/local/bin/python", "/app/premiumizer.py"]
