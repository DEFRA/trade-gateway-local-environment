# trade-gateway-local-environment

Docker Compose for running Trade Gateway services locally.

- [trade-gateway](https://github.com/DEFRA/trade-gateway)

## Prerequisites

### Dependencies

Install the following:
- [Docker](https://docs.docker.com/engine/)
- [Docker Compose](https://docs.docker.com/compose/)

### Environment variables

Create `.env` file in the root of the project and provide necessary secrets (copy `.env.example`).

## Usage

Start as follows:

```bash
docker compose up -d --build
```

Get a bearer token as follows:

```bash
curl -i -X POST http://localhost:3001/local/cognito/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "scope=trade-gateway-resource-srv/access" \
  --data-urlencode "sub=<example-sub>"
```

Stop as follows:

```bash
docker compose down
```

## Service API documentation

View service API documentation locally as follows:

- [trade-gateway](http://localhost:3000/redoc/index.html)

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government licence v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable
information providers in the public sector to license the use and re-use of their information under a common open
licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
