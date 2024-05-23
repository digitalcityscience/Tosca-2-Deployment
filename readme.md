# TOSCA Deployment with Docker

This document guides you through setting up a TOSCA deployment environment using Docker Compose for development purposes.

**Prerequisites**

* **VS Code:** [https://code.visualstudio.com/](https://code.visualstudio.com/) (integrated development environment)
* **Docker Desktop:** [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/) (containerization platform)

### Pre-Deployment Considerations

Before embarking on the deployment process, it's essential to familiarize yourself with these key guidelines:

**Environment Selection:**

* **Local Development:** Utilize the `docker-compose-dev.yml` file for streamlined development on your local machine (laptop).

**Port Mapping:**

* Port mapping plays a crucial role in ensuring proper application communication. Refer to the `docker-compose-dev.yml` file to view all port mappings for the various components. If no conflicting applications are running on your computer, the default ports will function seamlessly.
  * Application ports are also documented in either the `.env` file or `docker-compose-dev.yml` file for easy reference.
  * Key Access Points:
    * TOSCA Web App: http://localhost:8181
    * GeoServer: http://localhost:8080/geoserver/web
    * PostGIS Connection: localhost:5435

**Data Mapping:**

* Data mapping establishes a bridge between your local data and the containerized environment.
* For local vector data (e.g., GeoPackage, Shapefile), meticulously examine the `volumes` section for Geoserver within `docker-compose-dev.yml`. This section specifies how your local data directory is mapped to the container's file system. Detailed instructions on data mapping are provided later in the documentation.

**PostGIS Data Storage (Recommendation):**

* If you envision using PostGIS for data storage, we strongly recommend employing desktop GIS software like QGIS or ArcGIS to efficiently populate the database. Once data is successfully loaded, you can proceed with publishing it through GeoServer. Detailed guidance on PostGIS integration is available in a separate section (link or reference to the section).
  <br>
  [Loading data into Postgis](https://www.crunchydata.com/blog/loading-data-into-postgis-an-overview)
  [Getting started with Postgis ](https://docs.geoserver.org/main/en/user/gettingstarted/postgis-quickstart/index.html)
  [Define Postgis as Datastore in Geoserver](https://docs.geoserver.org/main/en/user/data/database/postgis.html)

<br>

### Steps

   **Clone the Repository**

   Clone this repository to your local machine using Git or download it as a ZIP archive.

   If you download as a ZIP file please open ZIP file to your target directory (`Desktop/Tosca-2-Deployment` in the example).

  **Open the Project in VS Code**

   - Launch VS Code.
   - In the File menu, select "Open Folder."
   - Navigate to the downloaded TOSCA repository directory and click "Open."

**Open a Terminal**

   - In VS Code, click the terminal and open new terminal. If you use small screen, you will see 3 dots (...) in the menu bar. Please click and see terminal menu.
   - Ensure the terminal working directory is set to the project root (`Desktop/Tosca-2-Deployment` in the example).

**Create the `.env` File**

   - **Recommended:** Generate the `.env` file by copying the `.env.example` file and renaming it to `.env`.
   - **Alternative:** Create a new file named `.env` in the project root.

  **Obtain your MapTiler API key**

  - Go to the MapTiler website: https://docs.maptiler.com/cloud/api/authentication-key/
  - Create an account if you don't have one already.
  - Navigate to the "Account" section and then "API Keys."
  - Create a new key specifically for local development (do not use the default key in production environments).
  - Copy your newly created API key.

  Update the .env file: Replace the placeholder value (=) with your actual MapTiler API key in the .env file. Ensure there are no spaces between the variable name and the key itself.

  For example:

  ``` 
  VITE_MAPTILER_API_KEY=your_actual_maptiler_api_key
  ```

   **Optional Environment Variables**

   The `.env.example` file might contain other configuration options. Review them and adjust as needed.  for your specific deployment.



 **Verify Data Mapping**

   If you're using Windows, ensure the data mapping between your local computer and the GeoServer container is correct. The data directory on your host machine should be mapped to `/mnt/data` within the container.

   For example, if your local data directory is `C:\Users\<username>\Desktop\geoserver_data`, the corresponding line in `docker-compose-dev.yml` should be:

   ```yaml
     volumes:
       - tosca-2-geoserver-production:/usr/share/geoserver/data_dir
       - LOCAL_FOLDER_FULL_PATH:/mnt/data
   ```

   When yoou upload data within Geoserver, you should go /mnt/data folder to see all data.

1. **Build and Run the System (First Time Only)**

   - To build the Docker images for the first time, run:

     ```bash
     docker-compose -f docker-compose-dev.yml build
     ```

   - To start the entire TOSCA deployment system in detached mode (background process), run:

     ```bash
     docker-compose -f docker-compose-dev.yml up -d
     ```

2. **Access the Applications**

   - Once the containers are running, you can access them using the following URLs:
     - GeoServer: http://localhost:${GEOSERVER_PORT}/geoserver
     - Web Application: http://localhost:8181

**Updating the Tool**

If you're a developer updating the TOSCA tool:

1. **Stop the Existing System**

   If the system is currently running, stop it using:

   ```bash
   docker-compose -f docker-compose-dev.yml down
   ```

2. **Update and Rebuild**

   - To update the tool code and rebuild the Docker images without using cached layers, run:

     ```bash
     docker-compose -f docker-compose-dev.yml build --no-cache
     ```

   - Restart the system using the command from step 7.

**Additional Notes**

- Consider using a version control system like Git to manage code changes.
- Refer to the official Docker Compose documentation for more advanced usage: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
- For production deployments, consult the TOSCA documentation for more robust configurations.
