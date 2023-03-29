# OCT Pallet

## Introduction

In this repository we will be working with the [Hermes IBC Relayer](https://hermes.informal.systems) in order to transfer fungible tokens ([ics-020](https://github.com/cosmos/ics/tree/master/spec/ics-020-fungible-token-transfer)) between two [ignite](https://ignite.com/) custom [Cosmos SDK](https://github.com/cosmos/cosmos-sdk) chains.

## Spin up two chains
Follow this instructions to run the two chains

### -------------------------------
### Start earth
### -------------------------------
Open a terminal prompt:

```
cd /your/path/to/oct-pallet

ignite chain serve -v -c earth.yml
```

### Restore key (Alice)

Open another terminal prompt in the same location (earth folder)

This command restores a key for a user in `earth` that we will be using during the workshop.

```
# restore the key for alice
earth keys add alice --recover --home .earth

# When prompted for the mnemonic please enter the following words:
picture switch picture soap flip dawn nerve easy rebuild company hawk stand menu rhythm unfold engine rug rally weapon raccoon glide mosquito lion dog

# query Alice's balance
earth --node tcp://localhost:26657 query bank balances $(earth --home .earth keys --keyring-backend="test" show alice -a)

```

### -------------------------------
### Start mars
### -------------------------------

Open another terminal prompt:

```
cd /your/path/to/oct-pallet

ignite chain serve -v  -c mars.yml
```
### Restore key (Bob)

Open another terminal prompt in the same location (mars folder)

This command restores a key for a user in `mars` that we will be using during the workshop.

```
# restore the key for bob
mars keys add bob --recover --home .mars

# When prompted for the mnemonic please enter the following words:
gaze clay walk tail shove sphere follow twenty agent basket viable gun popular decide vanish coyote guilt carry toward exhaust hour six scout chest

# query Bob's balance
mars --node tcp://localhost:26658 query bank balances $(mars --home .mars keys --keyring-backend="test" show bob -a)

```
## Install and config hermes

### Install hermes.
Please follow the [instructions to install](https://hermes.informal.systems/installation.html) it locally on your mahcine.

### Configure Keys for hermes

#### Add keys for two chains

These keys will be used by Hermes to sign transactions sent to each chain. The keys need to have a balance on each respective chain in order to pay for the transactions.

```
# add key for earth
hermes --config hermes.toml keys add --chain earth --key-file alice_key.json
# list keys
hermes --config hermes.toml keys list --chain earth
```

```
# add key for mars
hermes --config hermes.toml keys add --chain mars --key-file bob_key.json
# list keys
hermes --config hermes.toml keys list --chain mars

```

## Test Case
### Create client

Create a mars client on earth:

```
hermes --config hermes.toml create client --host-chain earth --reference-chain mars
```

Create a earth client on mars

```
hermes --config hermes.toml create client --host-chain mars --reference-chain earth
```

### TODO: add other test cases