<div align="center">

  <h1><i>Droid Builder</i></h1>

  [![Actions Status](https://github.com/rokibhasansagar/docker_droid-builder/workflows/Docker%20Builder/badge.svg)](https://github.com/rokibhasansagar/docker_droid-builder/actions)
  [![Container Builder](https://img.shields.io/badge/Powered%20By-Github%20Actions-blue?logo=github-actions)](https://github.com/features/actions "Know about Github Actions")
  [![Platform](https://img.shields.io/badge/Based%20On-Ubuntu%20Bionic-orange?logo=ubuntu)](https://ubuntu.com/download)

  [![Docker Image Size](https://img.shields.io/docker/image-size/fr3akyphantom/droid-builder/latest?cacheSeconds=3600)](#)
  [![Docker Image Latest Version](https://img.shields.io/docker/v/fr3akyphantom/droid-builder)](#)
  [![MicroBadger Layers](https://img.shields.io/microbadger/layers/fr3akyphantom/droid-builder/latest)](#)
  [![Latest Commit](https://images.microbadger.com/badges/commit/fr3akyphantom/droid-builder:latest.svg)](https://microbadger.com/images/fr3akyphantom/droid-builder:latest)
  [![Docker Pulls](https://img.shields.io/docker/pulls/fr3akyphantom/droid-builder)](https://hub.docker.com/r/fr3akyphantom/droid-builder "Show the Docker Repository")

  <h3><i>Standalone Docker Container based upon Updated Ubuntu Bionic 18.04 LTS for Building Android ROMs or Recovery Projects</i></h3>

</div>

---

### Get the Image

Pull the latest image by running the following command.

You might want to start the _bash_ as _root user_ by running `sudo -s`.

```bash
docker pull fr3akyphantom/droid-builder:latest
```

### Run the Container

```bash
docker run --privileged --rm -i \
  # optionally set/change the name/hostname of the container
  --name docker_droid-builder --hostname droid-builder \
  -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) \
  # mount working directory as volume
  -v "$HOME:/home/builder:rw,z" \
  # mount ccache volume too, host machine should have ccache installed for this
  -v "$HOME/.ccache:/srv/ccache" \
  fr3akyphantom/droid-builder:latest \
  /bin/bash
```
:reminder_ribbon: Remember to make `/home/builder/` the working directory for the container.

### Start the Build

When this Image runs as the droid-builder Container, You won't need to install any other softwares.

This Container has inbuilt openjdk8, adb+fastboot, wget, curl, git, repo, automake, cmake, clang, ccache, ninja, build-essential, python, and all the reqired dependencies and extra tools like wput, ghr, sshpass for Uploading/Publishing/Releasing.

Inside the Docker Container, run the following commands...

```bash
# make sure you are on the $HOME directory of the container,
# this is the working root path for the container
cd /home/builder/ || cd $HOME/

# change directory to any sub-folder (name as you like)
mkdir -p ${projectDir} && cd ${projectDir}

# set your github usename and email, required by repo binary
git config --global user.email $GitHubMail
git config --global user.name $GitHubName
git config --global color.ui true

# initialize the repo here to begin
repo init --depth 1 -q -u https://github.com/${DEMO_ORG}/${DEMO_MANIFEST}.git -b ${MANIFEST_BRANCH}

# sync the repo with maximum connections
# wait for the whole repo to be downloaded
repo sync -c -q --force-sync --no-clone-bundle --no-tags -j$(nproc --all)

# clone the specific device trees
git clone https://github.com/${DEMO_USER}/${DEVICE_REPONAME} device/${VENDOR}/${CODENAME}
# and other dependent repos too, if you need.

# Start the Build Process
export ALLOW_MISSING_DEPENDENCIES=true
source build/envsetup.sh
lunch ${BUILD_LUNCH}

# you can now delete the .repo folder if you need more space,
# but it is not recommended for multi-build or shared projects

# build only recovery image or make full ROM/otapackage
make -j$(nproc --all) recoveryimage || make -j$(($(nproc --all) / 2)) otapackage
```

### Well, there you have it!

You know where to find the Output of the Build.
Happy Building... :stuck_out_tongue_winking_eye: 
