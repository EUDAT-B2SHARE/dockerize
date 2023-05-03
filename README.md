# dockerize
Docker demo installation of B2SHARE

## Installation
```
cp b2share.env .env
docker-compose up
```

## Usage with B2SHARE configloader

With B2SHARE v2.3.0 a new configuration loader has been introduced. Because of this, all environment variables for b2share image has to start with prefix `B2SHARE_`

## Useful links

 * [B2SHARE training module](https://github.com/EUDAT-Training/B2SHARE-Training/tree/master/deploy)
 * [B2SHARE install notes](https://github.com/EUDAT-B2SHARE/b2share/blob/evolution/INSTALL.rst)

Upgrade guide for postgres upgrade [HERE](./upgrade.md)

