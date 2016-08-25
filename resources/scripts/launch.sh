#!/bin/sh

export POOL_SIZE=5
export MEM_LIMIT="512m"
export OVERPROVISION_FACTOR=2
export CPU_SHARES=$(( (1024*${OVERPROVISION_FACTOR})/${POOL_SIZE} ))
export IP=127.0.0.1

#sudo service docker start
#sudo docker build -t pyrho/minimal .

sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8000
sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j LOG --log-prefix='[TMPNB] '

export TOKEN=$( head -c 30 /dev/urandom | xxd -p )

# --restart=always # for docker run below
sudo docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=proxy \
            jupyter/configurable-http-proxy --default-target http://127.0.0.1:9999 \
            --port=8000 --api-port=8001

sudo docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=tmpnb \
            -e CONFIGPROXY_ENDPOINT=http://127.0.0.1:8001 \
            -v /var/run/docker.sock:/docker.sock \
            jupyter/tmpnb python orchestrate.py --image='pyrho/minimal' \
            --pool_size=$POOL_SIZE \
            --mem_limit=$MEM_LIMIT \
            --cpu_shares=$CPU_SHARES \
            --cull_timeout=600 \
            --redirect_uri="/notebooks/Prometheus.ipynb" \
            --command="jupyter notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port} --no-browser"

            # --command='start-notebook.sh "--NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port} --no-browser --NotebookApp.trust_xheaders=True"'
            # This is a script in https://github.com/jupyter/docker-stacks/blob/master/base-notebook/start-notebook.sh
