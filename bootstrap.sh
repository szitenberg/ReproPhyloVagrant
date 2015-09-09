#!/bin/bash
# update base image
sudo apt-get update
sudo apt-get -y -qq upgrade
sudo apt-get update -y -qq --fix-missing

# X11
sudo apt-get -y install xvfb libexif-dev

# install developer tools and dependencies
sudo apt-get -y -qq install build-essential git libzmq3-dev sqlite3 pandoc libcurl4-openssl-dev nodejs
sudo apt-get -y -qq install gcc-multilib g++-multilib libffi-dev libffi6 libffi6-dbg python-crypto \
  python-mox3 python-pil python-ply libssl-dev zlib1g-dev libbz2-dev libexpat1-dev libbluetooth-dev \
  libgdbm-dev dpkg-dev quilt autotools-dev libreadline-dev libtinfo-dev libncursesw5-dev tk-dev blt-dev \
  libssl-dev zlib1g-dev libbz2-dev libexpat1-dev libbluetooth-dev libsqlite3-dev libgpm2 mime-support \
  netbase net-tools bzip2 libreadline-dev
sudo apt-get -y -qq install wget curl

# install python modules
sudo apt-get -y -qq install python python-dev python-pip python-setuptools
sudo apt-get -y -qq build-dep python-lxml python-mysqldb python-numpy python-scipy python-qt4
sudo apt-get -y -qq build-dep python-biopython python-matplotlib python-pandas

# install reprophylo dependencies
sudo apt-get -y -qq install exonerate mafft muscle raxml

# install python 2.7.9
wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz
tar zxf Python-2.7.9.tgz
cd Python-2.7.9/
./configure --enable-ipv6
make
make install
rm -rf Python-2.7.9*
export PATH=/usr/local/bin:$PATH

# install ipython and dependencies
sudo easy_install --upgrade --quiet pip
sudo pip install --upgrade --quiet setuptools pip
sudo pip install --upgrade --quiet pyopenssl
sudo pip install --upgrade ipython["all"]
sudo pip install --upgrade ipython["notebook"]
#su - vagrant -c 'python -c "from IPython.external.mathjax import install_mathjax; install_mathjax()"'

# install other python dependencies
sudo apt-get install python-setuptools python-numpy python-qt4 python-scipy python-mysqldb python-lxml -y
sudo apt-get install python-biopython -y
sudo apt-get build-dep python-matplotlib -y
sudo apt-get install python-matplotlib -y

sudo pip install --quiet cloud dendropy ete2 pandas

# create local bin
mkdir -p ~/bin
mkdir -p ~/tools

# setup trimal, BayesTraits and pal2nal
cd ~/tools
# download
wget -c http://trimal.cgenomics.org/_media/trimal.v1.2rev59.tar.gz
wget -c http://www.evolution.rdg.ac.uk/BayesTraitsV2.0Files/Linux64/BayesTraitsV2.tar.gz
wget -c http://www.bork.embl.de/pal2nal/distribution/pal2nal.v14.tar.gz
wget -c http://megasun.bch.umontreal.ca/People/lartillot/www/phylobayes4.1b.tar.gz
# extract
tar -zxvf trimal.v1.2rev59.tar.gz
tar -zxvf BayesTraitsV2.tar.gz
tar -zxvf pal2nal.v14.tar.gz
tar -zxvf phylobayes4.1b.tar.gz
rm *.tar.gz
# install trimal
cd trimAl/source
make
chmod a+x trimal readal
# install BayesTraits
cd ../../BayesTraitsV2
chmod a+x BayesTraitsV2
# install pal2nal
cd ../pal2nal.v14
chmod a+x pal2nal.pl

# install phylobayes
cd ../phylobayes4.1b/data/
chmod a+x pb bpcomp tracecomp

# install raxmlHPC-PTHREADS-SSE3
chmod a+x /vagrant/reprophylo/raxmlHPC-PTHREADS-SSE3
cp /vagrant/reprophylo/raxmlHPC-PTHREADS-SSE3 ~/tools/.

# move files to vagrant home
mv ~/bin /home/vagrant
mv ~/tools /home/vagrant
cp /vagrant/reprophylo /home/vagrant

# create cert for notebook
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /home/vagrant/rpcert.pem \
  -out /home/vagrant/rpcert.pem -subj "/C=RP/ST=RP/L=RP/O=ReproPhylo/CN=ReproPhylo"

# setup git
su - vagrant -c 'git config --global user.email "reprophylo@repro.phylo"'

# setup symlinks
ln -s /home/vagrant/tools/trimAl/source/trimal /home/vagrant/bin/trimal
ln -s /home/vagrant/tools/trimAl/source/readal /home/vagrant/bin/readal
ln -s /home/vagrant/tools/BayesTraitsV2/BayesTraitsV2 /home/vagrant/bin/BayesTraitsV2
ln -s /home/vagrant/tools/pal2nal.v14/pal2nal.pl /home/vagrant/bin/pal2nal.pl
ln -s /home/vagrant/tools/raxmlHPC-PTHREADS-SSE3 /home/vagrant/bin/raxmlHPC-PTHREADS-SSE3
ln -s /home/vagrant/tools/phylobayes4.1b/data/pb /home/vagrant/bin/pb
ln -s /home/vagrant/tools/phylobayes4.1b/data/tracecomp /home/vagrant/bin/tracecomp
ln -s /home/vagrant/tools/phylobayes4.1b/data/bpcomp /home/vagrant/bin/bpcomp

# fix ownership
chown -R vagrant:vagrant /home/vagrant

# setup path
su - vagrant -c 'echo "export PATH=~/bin:/usr/local/bin:/vagrant/reprophylo:$PATH" >> /home/vagrant/.bashrc'
su - vagrant -c 'echo "export PYTHONPATH=/vagrant/reprophylo:$PYTHONPATH" >> /home/vagrant/.bashrc'


# create notebook shell script
cat << EOF > /home/vagrant/notebook.sh
#!/bin/bash
ipython notebook --NotebookApp.certfile='/home/vagrant/rpcert.pem'\
 --NotebookApp.ip='*' --NotebookApp.open_browser=False\
 --NotebookApp.password=u\'sha1:32d7842eb33f:b07722e1e9f912cf2bb0cb208944e979d54f716e\'\
 --NotebookApp.port=8888 --NotebookApp.notebook_dir='/vagrant_notebooks'\
 --KernelManager.control_port=60001 --KernelManager.shell_port=60002\ 
 --KernelManager.stdin_port=60003 --KernelManager.hb_port=60004\
 --KernelManager.iopub_port=60005
EOF

cat << EOF > /home/vagrant/startRP.sh
#!/bin/bash
xvfb-run /home/vagrant/notebook.sh
EOF

chmod a+x /home/vagrant/notebook.sh
chmod a+x /home/vagrant/startRP.sh
mv /home/vagrant/startRP.sh /home/vagrant/bin/.
