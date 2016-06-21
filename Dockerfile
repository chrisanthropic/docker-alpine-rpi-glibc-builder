FROM ctarwater/armhf-alpine-rpi-base

# Create our user and setup Alpine for building APKs
RUN apk --no-cache add alpine-sdk coreutils && \
    adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /packages && \
    chown builder:abuild /packages
        
USER builder
WORKDIR /home/builder

RUN abuild-keygen -a -i -n

RUN git clone --single-branch https://github.com/andyshinn/alpine-pkg-glibc upstream && \
    mkdir packages && \
    chown -R 1000 upstream packages && \
    cd upstream && \
    sed -i 's/arch=.*/arch="armhf"/g' APKBUILD && \
    sed -i 's/ld-linux-x86-64.so.2/ld-linux-armhf.so.3/g' APKBUILD && \
    sed -i 's/lib64/lib/g' APKBUILD && \
    sed -i 's/^source=.*/source="https:\/\/github.com\/armhf-docker-library\/glibc\/releases\/download\/2.22\/glibc-bin.tar.gz/' APKBUILD && \
    export MD5=2a9d468836dd45918d679ee53ae23542 && \
    sed -i "s/md5sums=\".*/md5sums=\"${MD5} glibc-bin.tar.gz/" APKBUILD && \
    abuild -r

#sudo apk add /home/builder/packages/builder/armhf/*.apk
