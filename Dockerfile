# build stage
FROM node:lts-alpine as build-stage
WORKDIR /app
RUN apk add git && git clone https://github.com/digitalcityscience/TOSCA-2.git /app
RUN npm install
COPY .env /app
RUN npm run build

# production stage
FROM nginx:stable-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]