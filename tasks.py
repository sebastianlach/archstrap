from invoke import task


def run(context, cmds):
    context.run(cmds)

@task
def clean(context):
    context.run("rm -rf data {archstrap,root,home}.tar {boot,root,home}.img")

@task
def build(context, docs=False):
    """
    docker build --build-arg user_login=slach -t slach/archstrap .
    """
    run(context, build.__doc__)

@task
def export(context):
    """
    docker run -it -d --rm --name archstrap slach/archstrap
    docker export archstrap > archstrap.tar
    docker stop archstrap
    """
    run(context, export.__doc__)

@task
def download(context):
    """
    docker run -it -d --rm --name boot littlelover/syslinux sh
    docker cp boot:/data/syslinux.img boot.img
    docker stop boot
    """
    run(context, download.__doc__)

@task
def extract(context, docs=False):
    """
    mkdir -p data
    tar -xvf archstrap.tar -C data && rm -rf archstrap.tar
    tar -cvf root.tar --exclude=home data
    tar -cvf home.tar --include=home data
    rm -rf data
    """
    run(context, extract.__doc__)

@task
def images(context):
    """
    docker run -it -v $PWD:/data --rm --privileged slach/genextimage root.tar root.ext4 10G
    docker run -it -v $PWD:/data --rm --privileged slach/genextimage home.tar home.ext4 2G
    """
    run(context, images.__doc__)
