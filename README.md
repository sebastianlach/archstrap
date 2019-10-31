# archstrap

[![Build Status](https://travis-ci.org/sebastianlach/archstrap.svg?branch=master)](https://travis-ci.org/sebastianlach/archstrap)


```shell
git clone --recursive git@github.com:sebastianlach/archstrap.git
pushd archstrap
docker build --no-cache --build-arg user_login=slach -t slach/archstrap .
```

```shell
docker run -it -d --rm --name archstrap slach/archstrap
docker export archstrap > archstrap.tar
docker stop archstrap
du -sh archstrap.tar
tar tvf archstrap.tar | wc -l
```

