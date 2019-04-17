mirth-connect
=============
**4/2019 Update** Upgraded to Mirth 3.7.1 and runs off of openjdk 11 (avoids Oracle license issues), set rhino (js engine) to es6 mode so you can use more modern javascript in transformers

Mirth Connect Docker image with properties read from environment variables.

# What is Mirth Connect?

[Mirth® Connect](https://www.mirth.com/Products-and-Services/Mirth-Connect) makes it easy to transform non-standard data into standard formats and to monitor multiple interfaces. Available to use for free under an open source license or with our commercial license, where additional enterprise features and support are at your disposal, it’s designed for seamless healthcare message integration, and is well-tested, delivering the advantages and innovation that comes with a large user base.


# How to use this image

This image forks https://github.com/brandonstevens/mirth-connect-docker and adds pulling in of environment variables into the `mirth.properties` file at startup.  This way you can set your database through environment variables.  Only the environment variables `$M_*` set in `mirth.properties_env` will be pulled off of the environment and substituted using the envsubst tool.

## Running Mirth Connect Server

Mirth Connect Server contains the back-end for the management interface and the integration engine component, which performs message filtering, transformation, and transmission.

    $ docker run -d -P tsystem/mirth-connect

## Configuring Mirth Connect Server

Create a configuration file for Mirth Connect Server from the default configuration file in SVN. Update the database properties to connect to a remote MySQL instance.

    $ svn export https://svn.mirthcorp.com/connect/trunk/server/conf/mirth.properties ~/mirth.properties
    $ vim mirth.properties
    ...
    database = mysql
    database.url = jdbc:mysql://prod-cluster.us-west-2.rds.amazonaws.com:3306/mirthdb
    database.username = mirth
    database.password = mirth

Launch the container and mount the configuration file:

    $ docker run -d -P \
       -e M_DATABASE \
       -e M_DATABASE_USER \
       -e M_DATABASE_PASSWORD \
       -e M_DATABASE_URL \
       tsystem/mirth-connect

There are many ways to set environment variables (explicitly, copied from your environment, from a separate file) using [-e, --env, --env-file](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e-env-env-file)

## Running Mirth Connect + Database locally with docker-compose
_this is for local development only_ do not use Docker for persistent data

- Clone this repo, or just copy the `docker-compose.yml` file.
- `docker-compose up`
  - This should just work, then navigate to http://localhost:8080 and connect to Mirth
  - What's happening here is Docker Compose is pulling this Mirth-Connect Docker image and a Postgres Docker image and telling them about each other with environment variables
  - Environment variables set in the `docker-compose.yml` file will be copied over to the `mirth.properties` file on startup.  This only supports a select subset of environment variables.  If you want to set other variables through the environment you'll have to either submit a PR and wait for someone to republish to docker hub or fork the project, add environment variables to `mirth.properties_env` and follow the Docker Hub publishing instructions below.

## Running Mirth Shell

In addition to the graphical Mirth Administrator, Mirth provides a command line interface known as the Mirth Shell.

First, get the name of the running Mirth Connect Server container:

    $ docker ps
    CONTAINER ID        IMAGE                                 COMMAND                CREATED             STATUS              PORTS                                              NAMES
    bf63b2b30e2c        brandonstevens/mirth-connect          "java -jar mirth-ser   26 minutes ago      Up 26 minutes       0.0.0.0:32769->8080/tcp, 0.0.0.0:32768->8443/tcp   fervent_torvalds

Using the name, link the Mirth Connect Server container to the Mirth Shell container:

    $ docker run -it --link fervent_torvalds:mirth-connect brandonstevens/mirth-connect java -jar mirth-cli-launcher.jar -a https://mirth-connect:8443 -u admin -p admin

## Publishing to Docker hub
One time only:
 - Create repo on docker hub
 - Make sure your docker user can write to it
 - `docker login` (with your hub.docker.com credentials on your terminal)

Each time you want to publish:
 - `docker build --build-arg MIRTH_CONNECT_VERSION=3.6.1.b220 -t tsystem/mirth-connect:3.6.1 .`
   - `build-arg MIRTH_CONNECT_VERSION` overwrites the version specified in the Dockerfile.  This way you don't need to change the Dockerfile every time there is a new version of Mirth
   - Find the [latest version number here](https://www.nextgen.com/products-and-services/NextGen-Connect-Integration-Engine-Downloads) and all [previous versions here](http://downloads.mirthcorp.com/archive/connect/)
   - `-t ...` tags this image
   - `.` the current directory with the Dockerfile in it
 - Copy the tag to other tags:
   - `docker tag tsystem/mirth-connect:3.6.1 tsystem/mirth-connect:3`
   - `docker tag tsystem/mirth-connect:3.6.1 tsystem/mirth-connect:3.6`
   - `docker tag tsystem/mirth-connect:3.6.1 tsystem/mirth-connect:latest`
 - Push all the tags to Dockerhub:
   - `docker push tsystem/mirth-connect:3.6.1`
   - `docker push tsystem/mirth-connect:3.6`
   - `docker push tsystem/mirth-connect:3`
   - `docker push tsystem/mirth-connect:latest`
