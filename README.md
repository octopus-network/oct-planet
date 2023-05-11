## Local test for provider chain <-> consumer chain

### Pre-install

Binaries:

- interchain-security-pd - [Interchain security](https://github.com/cosmos/interchain-security) version: v1.2.1
- interchain-security-cd
- hermes - [Hermes](https://github.com/informalsystems/hermes) version: v1.4.0

### Steps for the single node

Change the right `spawn_time` of consumer-proposal.json in `start_provider.sh`, and the consumer genesis can be got after the `spawn_time`.

```sh
cd scripts/single-node

bash start_provider.sh
bash start_consumer.sh
bash start_hermes.sh
```