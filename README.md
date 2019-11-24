<div align="center">

  <h1><i>Droid Builder</i></h1>

  [![Actions Status](https://github.com/rokibhasansagar/docker_droid-builder/workflows/Docker%20Builder/badge.svg)](https://github.com/rokibhasansagar/docker_droid-builder/actions)
  [![](https://images.microbadger.com/badges/version/fr3akyphantom/droid-builder.svg)](https://microbadger.com/images/fr3akyphantom/droid-builder "Get your own version badge on microbadger.com")
  [![](https://images.microbadger.com/badges/commit/fr3akyphantom/droid-builder.svg)](https://microbadger.com/images/fr3akyphantom/droid-builder "Get your own commit badge on microbadger.com")
  [![Docker Pulls](https://img.shields.io/docker/pulls/fr3akyphantom/droid-builder)](https://hub.docker.com/r/fr3akyphantom/droid-builder "Show the Docker Repository")

  <h3><i>Docker Container based upon Ubuntu Bionic 18.04 LTS for Building any Android ROM or Recovery Projects</i></h3>

</div>

---

#### This Image was Rebased From [@yshalsager/cyanogenmod:latest](https://hub.docker.com/r/yshalsager/cyanogenmod "Show the Docker Repository") which is a popular Docker Container used for Building Android ROMs, specially CyanogenMod13.

### Get the Image

Pull the latest image by running the following command.
You may also need to start the bash as root user by running `sudo -s`.

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
repo sync -c -f -q --force-sync --no-clone-bundle --no-tags -j32

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
make -j16 recoveryimage || make -j8 otapackage
```

### Well, there you have it!

You know where to find the Output of the Build.
Happy Building... :stuck_out_tongue_winking_eye: 
