### Docker compose for development

- Check docker-compose-dev file and port mapping. If you don't have any port conflict, you can use the same port mapping. For basic usage, you can skip this step.
- For basic usage, just copy .env.example and then change name to .env. You have to change VITE_MAPTILER_API_KEY from next page. You can skip other settings
- Go to Maptiler website and get the API key and put it in the .env file. If you don't have account please create one.
- https://cloud.maptiler.com/account/keys/ In this link you can get the API key. You can use Default use for local development but please create new key for production.
- When you create ENV file there is no gap between key and value. For example: MAPTILER_API_KEY=your_api_key
- Check your data mapping between your local computer and geoserver container. For this step, you C:\Users\%username%\Desktop\geoserver_data
  - Windows user: If you use powershell or CMD to run docker, you path should be like >> C:\Users\username\Desktop\geoserver_data:/mnt/data
- For first time :
  - docker compose -f docker-compose-dev.yml build
- Run your system :
  - docker compose -f docker-compose-dev.yml up -d
- Go to http://localhost:${GEOSERVER_PORT}/geoserver for geoserver.
- Go to http://localhost:8181 for web application.

### Docker compose for update the tool a

When you developer update the tool, you can update the tool with the following steps:

If system is working

- docker compose -f docker-compose-dev.yml down

Then you can update the tool.

- docker compose -f docker-compose-dev.yml build --no-cache
- docker compose -f docker-compose-dev.yml up -d
