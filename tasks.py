from invoke import task


def run(context, cmds):
    context.run(cmds)

@task
def clean(context):
    context.run("rm -rf data {archstrap,root,home}.tar {boot,root,home}.img")

@task
def build(context, cache=True):
    """
    docker build {} --target build --tag slach/archstrap \
        --build-arg archlinux_mirror_url=https://mirrors.kernel.org/archlinux .
    """
    run(context, build.__doc__.format('--no-cache' if not cache else ''))

@task
def export(context):
    """
    docker run -it -d --rm --name archstrap slach/archstrap sh
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
    tar -xf archstrap.tar -C data
    tar -cf root.tar --exclude=home -C data .
    tar -cf home.tar -C data/home .
    """
    run(context, extract.__doc__)

@task
def images(context):
    """
    docker run -v $PWD:/data --rm --privileged slach/genextimage root.tar root.img 10G
    docker run -v $PWD:/data --rm --privileged slach/genextimage home.tar home.img 2G
    """
    run(context, images.__doc__)
