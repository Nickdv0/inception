FROM debian:11
RUN apt-get update && apt-get install -y nginx openssl
COPY ./conf/nginx.conf /etc/nginx/
EXPOSE 80
RUN openssl req -x509 -nodes -days 365 \
	-subj "/C=US/ST=State/L=City/O=Organization/CN=nde-vant.42.fr" \
	-newkey rsa:2048 \
	-keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 443
