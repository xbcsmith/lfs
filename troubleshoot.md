## Troubleshoot

```bash
export LFS=$HOME/lfs/build
mkdir -pv $LFS
sudo mount /dev/sdd2 $LFS
sudo mkdir -p $LFS/boot
sudo mount /dev/sdd1 $LFS/boot/
sudo mount -v --bind /dev $LFS/dev
sudo mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
sudo mount -vt proc proc $LFS/proc
sudo mount -vt sysfs sysfs $LFS/sys
sudo mount -vt tmpfs tmpfs $LFS/run

cd $LFS
```

### login

```bash
sudo chroot "$LFS" /usr/bin/env -i HOME=/root TERM="$TERM" PS1='(lfs chroot) \u:\w\$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin /bin/bash --login +h
```

#### Logout and umount

```bash
logout
cd 
```

```bash
sudo umount -v $LFS/dev/pts
sudo umount -v $LFS/dev
sudo umount -v $LFS/run
sudo umount -v $LFS/proc
sudo umount -v $LFS/sys
sudo umount $LFS/boot
sudo umount $LFS
```


### Testing

```bash
qemu-system-x86_64 -nic tap,model=e1000 -drive format=raw,file=lfs-9.0-x86_64.img
```


### Modifying fstab

```bash
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order
/dev/sda1     /boot        ext4     defaults            1     1
/dev/sda2     /            ext4     defaults            1     1
## /dev/<yyy>     swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0

# End /etc/fstab
EOF

```


### Grub

`https://www.linux.com/tutorials/how-rescue-non-booting-grub-2-linux`



