ReproPhyloVagrant
=================
ReproPhylo is a reproducible phylogenetics pipeline. See http://hulluni-bioinformatics.github.io/ReproPhylo/.
  
This Vagrantfile creates a Ubuntu 14.04 LTS image with a working ReproPhylo installation.
  
Run the following to start the VM:

```
git clone https://github.com/szitenberg/ReproPhyloVagrant
cd ReproPhyloVagrant
vagrant up
vagrant ssh
```

Once in the VM you can run `startRP.sh` to start the Jupyter notebook server.  
This will be accessible through your web browser at [https://localhost:8888/](https://localhost:8888/).  
The default password for the notebook server is *reprophylo*.
  
This is a fork of https://github.com/gawbull/ReproPhyloVagrant  
Thanks to Dr. Steve Moss
