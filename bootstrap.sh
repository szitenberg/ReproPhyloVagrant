#!/bin/bash
# update base image
apt-get update
apt-get -y -qq upgrade

# install developer tools and dependencies
apt-get -y -qq install build-essential zlib1g-dev git libzmq3-dev sqlite3 libsqlite3-dev pandoc libcurl4-openssl-dev nodejs
apt-get -y -q install wget curl

# install python modules
apt-get -y -qq install python python-dev python-pip python-setuptools
apt-get -y -qq build-dep python-lxml python-mysqldb python-numpy python-scipy python-qt4
apt-get -y -qq build-dep python-biopython python-matplotlib python-pandas

# install reprophylo dependencies
apt-get -y -qq install exonerate mafft muscle raxml

# install ipython and dependencies
pip install --upgrade --quiet ipython["all"]
pip install --upgrade --quiet ipython["notebook"]
python -c "from IPython.external.mathjax import install_mathjax; install_mathjax()"

# install other python dependencies
pip install --upgrade --quiet biopython cloud dendropy ete2 lxml matplotlib mysql-python numpy pandas scipy

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

# move files to vagrant home
mv ~/bin /home/vagrant
mv ~/tools /home/vagrant
mv /vagrant/reprophylo /home/vagrant

# create cert for notebook
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /home/vagrant/rpcert.pem \
  -out /home/vagrant/rpcert.pem -subj "/C=RP/ST=RP/L=RP/O=ReproPhylo/CN=ReproPhylo"

# create notebook profile
su - vagrant -c 'ipython profile create nbserver'
cat << EOF > /home/vagrant/.ipython/profile_nbserver/ipython_notebook_config.py
c = get_config()
c.IPKernelApp.pylab = 'inline'  # if you want plotting support always
c.NotebookApp.certfile = u'/home/vagrant/rpcert.pem'
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.password = u'sha1:32d7842eb33f:b07722e1e9f912cf2bb0cb208944e979d54f716e'
c.NotebookApp.port = 8888
c.NotebookApp.notebook_dir = u'/vagrant_notebooks'
EOF

# setup git
su - vagrant -c 'git config --global user.email "reprophylo@repro.phylo"'

# setup symlinks
ln -s /home/vagrant/tools/trimAl/source/trimal /home/vagrant/bin/trimal
ln -s /home/vagrant/tools/trimAl/source/readal /home/vagrant/bin/readal
ln -s /home/vagrant/tools/BayesTraitsV2/BayesTraitsV2 /home/vagrant/bin/BayesTraitsV2
ln -s /home/vagrant/tools/pal2nal.v14/pal2nal.pl /home/vagrant/bin/pal2nal.pl

# fix ownership
chown -R vagrant:vagrant /home/vagrant

# setup path
su - vagrant -c 'echo "export PATH=~/bin:$PATH" >> ~/.bashrc'
su - vagrant -c 'echo "export PYTHONPATH=~/reprophylo:$PYTHONPATH" >> ~/.bashrc'

# create notebook shell script
su - vagrant -c 'echo "#!/bin/bash\nipython notebook --profile=nbserver &" > ~/notebook.sh'
chmod a+x /home/vagrant/notebook.sh
