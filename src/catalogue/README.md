# Catalogue

[![Go Report Card](https://goreportcard.com/badge/github.com/oracle-quickstart/oci-cloudnative)](https://goreportcard.com/report/github.com/oracle-quickstart/oci-cloudnative/tree/master/src/catalogue)

A microservices demo service that provides catalogue/product information stored on Oracle Autonomous Database.

This service is built, tested and released by Github Actions.

## Run Catalogue Service APIs on postman

[![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_catalogue]

## API Spec

Checkout the API Spec [here](https://mushop.docs.apiary.io)

## To build this service

### Go tools

In order to build the project locally you need to make sure that the repository directory is located in the correct
$GOPATH directory: $GOPATH/src/mushop/catalogue/. Once that is in place you can build by running:

```bash
cd $GOPATH/src/mushop/catalogue/cmd/cataloguesvc/
GO111MODULE=on go build -o catalogue
```

The result is a binary named `catalogue`, in the current directory.

### Docker

`docker-compose build`

### To run the service on port 8080

#### Go native

If you followed to Go build instructions, you should have a "catalogue" binary in $GOPATH/src/mushop/catalogue/cmd/cataloguesvc/.
To run it use:

```bash
./catalogue
```

Note: When doing development and running local, you need to set the variables to connect to the Oracle Autonomous Database. OADB_USER, OADB_PW and OADB_SERVICE need to be load as environment variables. Using [.env](https://docs.docker.com/compose/env-file/) file or EXPORT.

#### Docker

`docker-compose up`

## Check whether the service is alive

`curl http://localhost:8080/health`

## Use the service endpoints

`curl http://localhost:8080/catalogue`

## Test Zipkin

To test with Zipkin

```bash
docker-compose -f docker-compose-zipkin.yml build
docker-compose -f docker-compose-zipkin.yml up
```

It takes about 10 seconds to seed data

you should see it at:
[http://localhost:9411/](http://localhost:9411)

be sure to hit the "Find Traces" button.  You may need to reload the page.

when done you can run:

```bash
docker-compose -f docker-compose-zipkin.yml down
```

[postman_button_catalogue]: https://god.gw.postman.com/run-collection/29850-a9fbedc3-2178-442c-9bee-7fd8c52194b1?action=collection%2Ffork&collection-url=entityId%3D29850-a9fbedc3-2178-442c-9bee-7fd8c52194b1%26entityType%3Dcollection%26workspaceId%3D8e00caeb-8484-4be3-aa3c-3c3721e169b7
