#!/bin/bash
cd /root
apt update
apt install git make curl golang jq -y
git clone https://github.com/realiotech/realio-network.git && cd realio-network
git checkout tags/v0.6.2
make install
cp /root/go/bin/realio-networkd /usr/bin/
echo "=======End====="
realio-networkd version
realio-networkd init "$NodaName" --chain-id realionetwork_1110-2
curl https://raw.githubusercontent.com/realiotech/testnets/master/realionetwork_1110-2/genesis.json > /root/.realio-network/config/genesis.json
sed -i.bak -e "s/^seeds *=.*/seeds = \"aa194e9f9add331ee8ba15d2c3d8860c5a50713f@143.110.230.177:26656\"/;" /root/.realio-network/config/config.toml
sed -i.bak -e "s/^enable *=.*/enable = \"true\"/;" /root/.realio-network/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$rpsper,$rpsper\"|;" /root/.realio-network/config/config.toml
#Get a trusted chain height, and the associated block hash
number_bloc=`curl -s $rpsper/commit | jq .result.signed_header.header.height -r`
hash_bloc=`curl -s $rpsper/block?height=$number_bloc | jq -r .result.block_id.hash`
sed -i.bak -e "s/^trust_height *=.*/trust_height = $number_bloc/;" /root/.realio-network/config/config.toml
sed -i.bak -e "s/^trust_hash *=.*/trust_hash = \"$hash_bloc\"/;" /root/.realio-network/config/config.toml
peer="ecfd533285802f97ba35138cccc095d296afbc4c@65.108.79.57:55656,1e7e1faf277d19df05facebe2a7e403044662234@213.239.217.52:37656,79c1142dbc863f59a69d358f90c86cbcb5e7b3da@65.109.92.148:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peer\"/;" /root/.realio-network/config/config.toml
#Edit snapshot config
sed -i.bak -e "s/^snapshot-interval *=.*/snapshot-interval = 500/;" /root/.realio-network/config/app.toml
sed -i.bak -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = 2/;" /root/.realio-network/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = 100/;" /root/.realio-network/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = 10/;" /root/.realio-network/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-interval = 500/;" /root/.realio-network/config/app.toml
sed -i.bak -e "s_"tcp://127.0.0.1:26657"_"tcp://0.0.0.0:26657"_;" /root/.realio-network/config/config.toml
realio-networkd start
