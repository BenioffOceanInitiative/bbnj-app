## load vector tile dynamic db

```bash
# log onto server
ssh root@ssh.calcofi.io

# get shell in postgis container
docker exec -it postgis bash

# create database bbnj
createdb -U admin bbnj

# cyberduck copy Gdrive bbnj-app/data/* via SFTP root@ssh.calcofi.io
#   to /share/data/bbnj
cd /share/data/bbnj
ogr2ogr -f PostgreSQL PG:"dbname=gis user=admin" hex_res2.geojson -nln roads

```
