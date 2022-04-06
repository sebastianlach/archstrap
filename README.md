# `archstrap`

[![CircleCI](https://circleci.com/gh/sebastianlach/archstrap/tree/master.svg?style=svg)](https://circleci.com/gh/sebastianlach/archstrap/tree/master)
[![CodeFactor](https://www.codefactor.io/repository/github/sebastianlach/archstrap/badge)](https://www.codefactor.io/repository/github/sebastianlach/archstrap)
[![License](https://img.shields.io/badge/license-GNU-green.svg)](https://shields.io/)

### Build
```shell
docker build --build-arg flavour=device/generic --build-arg login=username .
```

### Configure

#### Timezone
```shell
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
```
