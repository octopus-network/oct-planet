#!/bin/bash
set -eux

bash start_provider.sh
bash start_consumer.sh
bash start_hermes.sh