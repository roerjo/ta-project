FROM nginx:1.21.1-alpine

COPY ./index.html /usr/share/nginx/html

EXPOSE 80
