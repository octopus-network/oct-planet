#!/bin/bash
set -eux

source set_env.sh

bash start_provider.sh
bash start_consumer.sh
bash start_hermes.sh