action :install_ubuntu do
  bash "start-#{new_resource.name}" do
    user "root"
    code <<-EOF
# https://gist.github.com/CBarraford/8850424
mkdir work
cd work
wget http://sourceforge.net/projects/e1000/files/ixgbevf%20stable/2.16.1/ixgbevf-2.16.1.tar.gz
tar zxf ixgbevf-2.16.1.tar.gz
# https://gist.github.com/defila-aws/44946d3a3c0874fe3d17
curl -L -O https://gist.github.com/defila-aws/44946d3a3c0874fe3d17/raw/af64c3c589811a0d214059d1e4fd220a96eaebb3/patch-ubuntu_14.04.1-ixgbevf-2.16.1-kcompat.h.patch
cd ixgbevf-2.16.1/src
patch -p5 <../../patch-ubuntu_14.04.1-ixgbevf-2.16.1-kcompat.h.patch
sudo su
# aptitude install -y build-essential
make install
modprobe ixgbevf
update-initramfs -c -k all
echo "options ixgbevf InterruptThrottleRate=1,1,1,1,1,1,1,1" > /etc/modprobe.d/ixgbevf.conf
cd ../../..
rm -Rf work
#reboot
  EOF
    not_if "modinfo ixgbevf | grep 'ixgbevf.ko'"
  end
  new_resource.updated_by_last_action(true)

end


action :install_redhat do
  bash "start-#{new_resource.name}" do
    user "root"
    code <<-EOF
# sudo yum update && sudo yum upgrade -y
  sudo yum install -y dkms
  wget "sourceforge.net/projects/e1000/files/ixgbevf stable/2.14.2/ixgbevf-2.14.2.tar.gz"
  tar -xzf ixgbevf-2.14.2.tar.gz
  sudo mv ixgbevf-2.14.2 /usr/src/
  echo "PACKAGE_NAME=\"ixgbevf\"
PACKAGE_VERSION=\"2.14.2\"
CLEAN=\"cd src/; make clean\"
MAKE=\"cd src/; make BUILD_KERNEL=${kernelver}\"
BUILT_MODULE_LOCATION[0]=\"src/\"
BUILT_MODULE_NAME[0]=\"ixgbevf\"
DEST_MODULE_LOCATION[0]=\"/updates\"
DEST_MODULE_NAME[0]=\"ixgbevf\"
AUTOINSTALL=\"yes\"
" >  /usr/src/ixgbevf-2.14.2/dkms.conf
  sudo dkms add -m ixgbevf -v 2.14.2
  sudo dkms build -m ixgbevf -v 2.14.2
  sudo dkms install -m ixgbevf -v 2.14.2
  cp -p /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
  dracut -f  
  cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-ens3
  EOF
    not_if "modinfo ixgbevf | grep 'ixgbevf.ko'"
  end
  new_resource.updated_by_last_action(true)

end
