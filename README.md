# `archstrap`

[![CircleCI](https://circleci.com/gh/sebastianlach/archstrap/tree/master.svg?style=svg)](https://circleci.com/gh/sebastianlach/archstrap/tree/master)
[![License](https://img.shields.io/badge/license-GNU-green.svg)](https://shields.io/)

### Build
```shell
docker build --build-arg flavour=device/generic --build-arg login=mylogin --tag slach/archstrap .
```

### Configure
```shell
ln -s /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
```
