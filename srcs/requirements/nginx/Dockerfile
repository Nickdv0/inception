FROM debian:11
RUN apt-get update && apt-get install -y nginx openssl && \
	rm -rf /var/lib/apt/lists/*
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
RUN openssl req -x509 -nodes -days 365 \
	-subj "/C=CH/ST=Vaud/L=Lausanne/O=42Lausanne/CN=nde-vant.42.fr" \
	-newkey rsa:2048 \
	-keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt && \
	chmod 600 /etc/ssl/private/nginx-selfsigned.key
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 443
