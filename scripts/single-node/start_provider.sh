#!/bin/bash
set -eux

source set_env.sh

# Clean start
pkill -f $PROVIDER_BINARY &> /dev/null || true
rm -rf $PROVIDER_HOME
sleep 1

#######VALIDATOR#######################
$PROVIDER_BINARY_PATH init $PROVIDER_MONIKER --home $PROVIDER_HOME --chain-id $PROVIDER_CHAIN_ID
$JQ_BINARY_PATH ".app_state.gov.voting_params.voting_period = \"60s\" | .app_state.staking.params.unbonding_time = \"600s\" | .app_state.provider.params.template_client.trusting_period = \"300s\"" \
   $PROVIDER_HOME/config/genesis.json > \
   $PROVIDER_HOME/edited_genesis.json && mv $PROVIDER_HOME/edited_genesis.json $PROVIDER_HOME/config/genesis.json
sleep 1

# Create account keypair
$PROVIDER_BINARY_PATH keys add $VALIDATOR --home $PROVIDER_HOME $KEYRING --output json > $PROVIDER_HOME/keypair.json 2>&1
sleep 1
$PROVIDER_BINARY_PATH keys add $PROVIDER_DELEGATOR --home $PROVIDER_HOME $KEYRING --output json > $PROVIDER_HOME/keypair_delegator.json 2>&1
sleep 1

# Add stake to user
$PROVIDER_BINARY_PATH add-genesis-account $($JQ_BINARY_PATH -r .address $PROVIDER_HOME/keypair.json) $TOTAL_COINS --home $PROVIDER_HOME $KEYRING
sleep 1
$PROVIDER_BINARY_PATH add-genesis-account $($JQ_BINARY_PATH -r .address $PROVIDER_HOME/keypair_delegator.json) $TOTAL_COINS --home $PROVIDER_HOME $KEYRING
sleep 1

# Stake 1/1000 user's coins
$PROVIDER_BINARY_PATH gentx $VALIDATOR $STAKE_COINS --chain-id $PROVIDER_CHAIN_ID --home $PROVIDER_HOME $KEYRING --moniker $VALIDATOR
sleep 1

####################GENTX AND DISTRIBUTE GENESIS##############################
$PROVIDER_BINARY_PATH collect-gentxs --home $PROVIDER_HOME
sleep 1

#################### Start the chain node ###################
$PROVIDER_BINARY_PATH start \
	--home $PROVIDER_HOME \
	--rpc.laddr tcp://$PROVIDER_RPC_LADDR \
	--grpc.address $PROVIDER_GRPC_ADDR \
	--address tcp://${NODE_IP}:26655 \
	--p2p.laddr tcp://${NODE_IP}:26656 \
	--grpc-web.enable=false \
    --trace \
    &> $PROVIDER_HOME/logs &
sleep 10

# Build consumer chain proposal file
tee $PROVIDER_HOME/consumer-proposal.json<<EOF
{
    "title": "Create consumer chain",
    "description": "First consumer chain",
    "chain_id": "consumer",
    "initial_height": {
        "revision_number": 0,
        "revision_height": 1
    },
    "genesis_hash": "520df96a862c30f53e67b1277e6834ab4bd59dfdd08c781d1b7cf3813080fb28",
    "binary_hash": "59184916f3e85aa6fa24d3c12f1e5465af2214f13db265a52fa9f4617146dea5",
    "spawn_time": "2023-05-11T14:50:00.000000000-00:00",
    "unbonding_period": 1728000000000000,
    "ccv_timeout_period": 2419200000000000,
    "transfer_timeout_period": 3600000000000,
    "consumer_redistribution_fraction": "0.75",
    "blocks_per_distribution_transmission": 1000,
    "historical_entries": 10000,
    "deposit": "10000001stake"
}
EOF

$PROVIDER_BINARY_PATH tx gov submit-proposal consumer-addition $PROVIDER_HOME/consumer-proposal.json $TX_FLAGS \
	--chain-id $PROVIDER_CHAIN_ID --node tcp://$PROVIDER_RPC_LADDR --from $VALIDATOR --home $PROVIDER_HOME $KEYRING -b block -y
sleep 1

# Vote yes to proposal
$PROVIDER_BINARY_PATH tx gov vote 1 yes --from $VALIDATOR --chain-id $PROVIDER_CHAIN_ID --node tcp://$PROVIDER_RPC_LADDR --home $PROVIDER_HOME -b block -y $KEYRING
sleep 5