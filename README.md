# docker-wordpress

Start by setting required variables in the shell environment e.g. "MYSQL_ROOT_PASSWORD":

```
$ openssl rand 12 -base64
$ export MYSQL_ROOT_PASSWORD=random-secret
$ export WORDPRESS_DB_PASSWORD=random-secret
$ export WORDPRESS_DB_NAME=some-db-name
$ export WORDPRESS_DB_USER=some-db-user
```

```
$ docker-compose up -d
```

Check that both containers are up and running:

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
cf53b21038a2        wordpress           "/entrypoint.sh apach"   33 hours ago        Up 15 minutes       0.0.0.0:8080->80/tcp   dockerwordpress_wordpress_1
7708ddf23960        mysql               "docker-entrypoint.sh"   33 hours ago        Up 15 minutes       3306/tcp               dockerwordpress_db_1
```

Using your preferred browser, connect to Wordpress typing "localhost:8080".

```
$ docker-machine create -d virtualbox node-1
$ docker-machine create -d virtualbox node-2
$ docker-machine create -d virtualbox node-3
```

```
$ eval $(docker-machine env node-1)

$ docker swarm init --advertise-addr $(docker-machine ip node-1)
Swarm initialized: current node (9rijc3ony5hbxufsyaasq7zu1) is now a manager.

To add a worker to this swarm, run the following command:
    docker swarm join \
    --token SWMTKN-1-0xf2d1at1cjibi8yinh77vredwpzccx29ll9pljnfbjuo4he3m-0sr5gel42ygi6hqjxddwbgqwm \
    192.168.99.100:2377

To add a manager to this swarm, run the following command:
    docker swarm join \
    --token SWMTKN-1-0xf2d1at1cjibi8yinh77vredwpzccx29ll9pljnfbjuo4he3m-1ehe39rc51q4afr9yx2ds718u \
    192.168.99.100:2377

$ TOKEN = $(docker swarm join-token -q worker)
```

```
$ eval $(docker-machine env node-2)
$ docker swarm join --token $TOKEN $(docker-machine ip node-1)
This node joined a swarm as a worker.

$ eval $(docker-machine env node-3)
$ docker swarm join --token $TOKEN $(docker-machine ip node-1)
This node joined a swarm as a worker.
```

```
$ docker network create --driver overlay private
1rh5un8kb202d9fdv4crx6461
```

```
$ eval $(docker-machine env node-1)
$ docker service create --name db -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" -e MYSQL_DATABASE="${WORDPRESS_DB_NAME}" -e MYSQL_USER="${WORDPRESS_DB_USER}" -e MYSQL_PASSWORD="${WORDPRESS_DB_PASSWORD}" --network private mysql
```

```
$ docker service create --name some-wordpress -e WORDPRESS_DB_HOST=db -e WORDPRESS_DB_USER="${WORDPRESS_DB_USER}" -e WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD}" -e WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME}" -p 8080:80 --network private wordpress
```

```
$ docker service scale some-wordpress=3
some-wordpress scaled to 3

$ docker service ps some-wordpress
ID                         NAME              IMAGE      NODE    DESIRED STATE  CURRENT STATE            ERROR
9cpmhygsjh1n6kgsdczl5az6n  some-wordpress.1  wordpress  node-1  Running        Running 2 minutes ago
3c9jcbwgtzkkr9p5r635zldpy  some-wordpress.2  wordpress  node-2  Running        Preparing 3 seconds ago
bf0w1ymrzxi2e5tihpu4o1835  some-wordpress.3  wordpress  node-2  Running        Preparing 3 seconds ago
```
