# trade-gateway-local-environment

Docker Compose for running Trade Gateway services locally.

- [trade-gateway](https://github.com/DEFRA/trade-gateway)
- [trade-gateway-publisher](https://github.com/DEFRA/trade-gateway-publisher)
- [trade-traces-poc](https://github.com/DEFRA/trade-traces-poc)
- [trade-tracesnt-stub](https://github.com/DEFRA/trade-tracesnt-stub)

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
docker compose pull
docker compose up -d
```

Every service runs from its published `defradigital/*` image at `latest`. Pin one by setting its
version in `.env`, e.g. `TRADE_TRACESNT_STUB=0.30.0`.

Get a bearer token as follows:

```bash
curl -i -X POST http://localhost:8080/local/cognito/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "scope=trade-gateway-resource-srv/access" \
  --data-urlencode "sub=<example-sub>"
```

Stop as follows:

```bash
docker compose down
```

## TRACES targets

`trade-gateway` talks to the stub's simulator by default. To use EU acceptance instead, set
`TRACES_NT_BASE_URL` and the `TRACES_NT_CREDENTIALS_*` variables in `.env` (see `.env.example`).

`trade-traces-poc` runs on <http://localhost:8090> and chooses its target by URL prefix. Unprefixed
URLs go to **EU acceptance**:

- `/ched/{id}`: EU acceptance (needs real credentials in `.env`)
- `/simulator/ched/{id}`: the stub's simulator
- `/mock/ched/{id}`: the stub's WireMock
- `/proxy/ched/{id}`: the stub's recording proxy to EU acceptance

Seed the simulator through its control API on <http://localhost:3000/control>; see the
[trade-tracesnt-stub README](https://github.com/DEFRA/trade-tracesnt-stub).

## Service API documentation

View service API documentation locally as follows:

- [trade-gateway](http://localhost:8080/redoc/index.html)
- [trade-traces-poc](http://localhost:8090/redoc/index.html)

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
