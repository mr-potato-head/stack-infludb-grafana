
# stack-infludb-grafana-jeedom

## Prerequisites
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install vim git docker.io docker-compose
```

## Clone repository
```
git clone https://github.com/mr-potato-head/stack-infludb-grafana-jeedom.git
```

## Setup
```
cd stack-infludb-grafana-jeedom
chmod +x setup.sh
sudo usermod -aG docker $USER
./setup.sh
```

## Use
```
# Start stack
docker-compose up

# Stop stack
docker-compose down
```

InfluxBD GUI is available here:
```
\<ip or localhost\>:8086
```
Grafana GUI is available here:
```
\<ip or localhost\>:3000
```
Portainer GUI is available here:
```
\<ip or localhost\>:9000
```

Direct local access:
InfluxDB: [http://localhost:8086]
Grafana: [http://localhost:3000]
Portainer: [http://localhost:9000]