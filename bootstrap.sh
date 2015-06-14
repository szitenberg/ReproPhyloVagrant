#!/bin/bash
# update base image
apt-get update
apt-get -y -qq upgrade

# install developer tools and dependencies
apt-get -y -qq install build-essential zlib1g-dev git libzmq3-dev sqlite3 libsqlite3-dev pandoc libcurl4-openssl-dev nodejs
apt-get -y -q install wget curl

# install python modules
apt-get -y -qq install python python-dev python-pip python-setuptools
apt-get -y -qq install python-numpy python-scipy python-qt4 python-mysqldb python-lxml python-biopython python-pandas
apt-get -y -qq build-dep python-matplotlib
apt-get -y -qq install python-matplotlib
apt-get -y -qq build-dep ipython ipython-notebook
apt-get -y -qq install ipython ipython-notebook

# install reprophylo dependencies
apt-get -y -qq install exonerate mafft muscle raxml

# install other python dependencies
pip install --upgrade --force-reinstall --quiet cloud dendropy ete2

# create local bin
mkdir -p ~/bin
mkdir -p ~/tools

# setup trimal, BayesTraits and pal2nal
cd ~/tools
# download
wget -c http://trimal.cgenomics.org/_media/trimal.v1.2rev59.tar.gz
wget -c http://www.evolution.rdg.ac.uk/BayesTraitsV2.0Files/Linux64/BayesTraitsV2.tar.gz
wget -c http://www.bork.embl.de/pal2nal/distribution/pal2nal.v14.tar.gz
# extract
tar -zxvf trimal.v1.2rev59.tar.gz
tar -zxvf BayesTraitsV2.tar.gz
tar -zxvf pal2nal.v14.tar.gz
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
# move file to vagrant home
mv ~/bin /home/vagrant
mv ~/tools /home/vagrant

# clone ReproPhylo
git clone https://github.com/HullUni-bioinformatics/ReproPhylo.git /home/vagrant/ReproPhylo

# create cert for notebook
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /home/vagrant/key.pem \
  -out /home/vagrant/key.pem -subj "/C=RP/ST=RP/L=RP/O=ReproPhylo/CN=ReproPhylo"

# setup symlinks
ln -s /home/vagrant/tools/trimAl/source/trimal /home/vagrant/bin/trimal
ln -s /home/vagrant/tools/trimAl/source/readal /home/vagrant/bin/readal
ln -s /home/vagrant/tools/BayesTraitsV2/BayesTraitsV2 /home/vagrant/bin/BayesTraitsV2
ln -s /home/vagrant/tools/pal2nal.v14/pal2nal.pl /home/vagrant/bin/pal2nal.pl

# fix ownership
chown -R vagrant:vagrant /home/vagrant

# setup path
su - vagrant -c 'echo "export PATH=~/bin:$PATH" >> ~/.bashrc'
