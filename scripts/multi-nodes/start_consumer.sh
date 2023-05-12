#!/bin/bash
set -eux

source set_env.sh

# Clean start
pkill -f $CONSUMER_BINARY &> /dev/null || true
rm -rf $CONSUMER_HOME
rm -rf $CONSUMER_HOME1
sleep 1

################CONSUMER############################

# Build genesis file and node directory structure
$CONSUMER_BINARY_PATH init --chain-id $CONSUMER_CHAIN_ID $CONSUMER_MONIKER --home $CONSUMER_HOME
sleep 1

# Add ccv section
if ! $PROVIDER_BINARY_PATH query provider consumer-genesis "$CONSUMER_CHAIN_ID" --node "$PROVIDER_NODE_ADDRESS" --output json > "$CONSUMER_HOME"/consumer_section.json; 
then
       echo "Failed to get consumer genesis for the chain-id '$CONSUMER_CHAIN_ID'! Finalize genesis failed. For more details please check the log file in output directory."
       exit 1
fi

$JQ_BINARY_PATH -s '.[0].app_state.ccvconsumer = .[1] | .[0]' "$CONSUMER_HOME"/config/genesis.json "$CONSUMER_HOME"/consumer_section.json > "$CONSUMER_HOME"/genesis_consumer.json && \
	mv "$CONSUMER_HOME"/genesis_consumer.json "$CONSUMER_HOME"/config/genesis.json

# Modify genesis params
$JQ_BINARY_PATH ".app_state.ccvconsumer.params.blocks_per_distribution_transmission = \"70\"" \
  $CONSUMER_HOME/config/genesis.json > \
   $CONSUMER_HOME/edited_genesis.json && mv $CONSUMER_HOME/edited_genesis.json $CONSUMER_HOME/config/genesis.json
sleep 1

# Create user account keypair
$CONSUMER_BINARY_PATH keys add $CONSUMER_USER $KEYRING --home $CONSUMER_HOME --output json > $CONSUMER_HOME/consumer_keypair.json 2>&1
sleep 1

# Add account in genesis (required by Hermes)
$CONSUMER_BINARY_PATH add-genesis-account $($JQ_BINARY_PATH -r .address $CONSUMER_HOME/consumer_keypair.json) 1000000000stake --home $CONSUMER_HOME
sleep 1

# Copy validator key files
cp $PROVIDER_HOME/config/priv_validator_key.json $CONSUMER_HOME/config/priv_validator_key.json
cp $PROVIDER_HOME/config/node_key.json $CONSUMER_HOME/config/node_key.json

#######CHAIN2#######
$CONSUMER_BINARY_PATH init --chain-id $CONSUMER_CHAIN_ID $CONSUMER_MONIKER --home $CONSUMER_HOME1
sleep 1

#copy genesis
cp $CONSUMER_HOME/config/genesis.json $CONSUMER_HOME1/config/genesis.json

cp $PROVIDER_HOME1/config/priv_validator_key.json $CONSUMER_HOME1/config/priv_validator_key.json
cp $PROVIDER_HOME1/config/node_key.json $CONSUMER_HOME1/config/node_key.json

##########SET CONFIG.TOML#####################
# Set default client port
sed -i -r "/node =/ s/= .*/= \"tcp:\/\/${CONSUMER_RPC_LADDR1}\"/" $CONSUMER_HOME1/config/client.toml
sed -i -r "/node =/ s/= .*/= \"tcp:\/\/${CONSUMER_RPC_LADDR}\"/" $CONSUMER_HOME/config/client.toml
node=$($CONSUMER_BINARY_PATH tendermint show-node-id --home $CONSUMER_HOME)
node1=$($CONSUMER_BINARY_PATH tendermint show-node-id --home $CONSUMER_HOME1)
sed -i -r "/persistent_peers =/ s/= .*/= \"$node1@localhost:26636\"/" "$CONSUMER_HOME"/config/config.toml
sed -i -r "/persistent_peers =/ s/= .*/= \"$node@localhost:26646\"/" "$CONSUMER_HOME1"/config/config.toml

sed -i -r "114s/.*/address = \"tcp:\/\/0.0.0.0:1318\"/" "$CONSUMER_HOME1"/config/app.toml

# Start the chain
$CONSUMER_BINARY_PATH start \
       --home $CONSUMER_HOME \
       --rpc.laddr tcp://${CONSUMER_RPC_LADDR} \
       --grpc.address ${CONSUMER_GRPC_ADDR} \
       --address tcp://${NODE_IP}:26645 \
       --p2p.laddr tcp://${NODE_IP}:26646 \
       --grpc-web.enable=false \
       --log_level trace \
       --trace \
       &> $CONSUMER_HOME/logs &
sleep 10

$CONSUMER_BINARY_PATH start \
       --home $CONSUMER_HOME1 \
       --rpc.laddr tcp://${CONSUMER_RPC_LADDR1} \
       --grpc.address ${CONSUMER_GRPC_ADDR1} \
       --address tcp://${NODE_IP}:26635 \
       --p2p.laddr tcp://${NODE_IP}:26636 \
       --grpc-web.enable=false \
       --log_level trace \
       --trace \
       &> $CONSUMER_HOME1/logs &        
sleep 10