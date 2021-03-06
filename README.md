Prometheus: Modelling as a Service
==================================

This is a repository for building a customised [tmpnb](https://github.com/jupyter/tmpnb) server for optogenetics with [PyRhO](https://github.com/ProjectPyRhO/PyRhO) installed and configured. Credit to the [Jupyter team](https://github.com/orgs/jupyter/people) for their work on tmpnb as one of the many great [Jupyter projects](https://github.com/jupyter)!

For updates on PyRhO, follow us on [twitter (@ProjectPyRhO)](https://twitter.com/ProjectPyRhO).

Quickstart: Try PyRhO
---------------------

Simply go to [try.projectpyrho.org](http://try.projectpyrho.org) and enjoy!

Further Information
-------------------

A paper introducing Prometheus and Modelling as a Service (MaaS) can be found [here](https://dx.doi.org/10.1109/BioCAS.2016.7833795). If you use or adapt this work, please use the following citation:

Evans, B. D. and Nikolic, K. (2016) "From Bytes to Insights with Modelling as a Service: A new paradigm for computational modelling illustrated with PyRhO”, in *2016 IEEE Biomedical Circuits and Systems Conference (BioCAS)*, Shanghai, China. p316–319. [doi:10.1109/BioCAS.2016.7833795](https://dx.doi.org/10.1109/BioCAS.2016.7833795)

```
@InProceedings{Evans+Nikolic2016c,
  author = {Evans, Benjamin D. and Nikolic, Konstantin},
  booktitle = {2016 IEEE Biomedical Circuits and Systems Conference (BioCAS)}, 
  title = {From Bytes to Insights with Modelling as a Service: A new paradigm for computational modelling illustrated with {PyRhO}},
  year = {2016},
  month = {Oct},
  isbn = {978-1-5090-2959-4},
  location = {Shanghai, China},
  pages = {316--319},
  publisher = {IEEE},
  address = {New York, NY, USA},
  doi = {10.1109/BioCAS.2016.7833795}, 
}
```

Interactive Docker image
------------------------

#### To run the PyRhO docker image:

Clone the repository: `git clone https://github.com/ProjectPyRhO/Prometheus.git && cd Prometheus`
Start the docker service e.g.: `sudo service docker start`
Then run these commands to build the image and launch the notebook:

```bash
docker build -t pyrho/minimal .
docker run -p 8888:8888 -it pyrho/minimal
```

Finally go to your browser and open `localhost:8888`.

N.B. If you are using docker machine, you will need to replace `localhost` with the IP address of the host, obtained with the following command: `docker-machine ip`.

Build Prometheus
----------------

#### Create an account to run the portal and disable root access
See [this guide](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04) for details including generating ssh keys.

```bash
adduser monty
gpasswd -a monty sudo
sudo nano /etc/ssh/sshd_config
```

Edit the sshd_config file to disable root login:
> PermitRootLogin no

Then restart the ssh daemon:

`service ssh restart`

Log out then log back in with the new (non-root) user account.
Finally update the system, install docker, build the image and launch the server!

```bash
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install make
git clone https://github.com/ProjectPyRhO/Prometheus.git
cd Prometheus
make setup
make image
make launch
```

Useful commands
---------------

#### Clean docker images

`make clean`

Alternatively:

```bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rm $(docker ps -qa --no-trunc --filter "status=exited")
docker rmi $(docker images -q --no-trunc --filter "dangling=true")
```

#### Check logs

```bash
make log-proxy
make log-tmpnb
sudo iptables -L
```

N.B. After an os update it may be necessary to run:
`sudo apt-get install linux-image-extra-$(uname -r)`
