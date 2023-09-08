#!/bin/bash
DATADIR="/app/node/logs/"

BPACCOUNT=eosio

if [ ! -d $DATADIR ]; then
  mkdir -p $DATADIR;
fi

ARCH=`uname -m`

if [ "${ARCH}" = "x86_64" ]; then
   EOSVM=eos-vm-jit
else
   EOSVM=eos-vm
fi

nodeos \
--plugin eosio::net_plugin \
--plugin eosio::net_api_plugin \
--plugin eosio::producer_plugin \
--plugin eosio::producer_api_plugin \
--plugin eosio::chain_plugin \
--plugin eosio::chain_api_plugin \
--plugin eosio::http_plugin \
--plugin eosio::state_history_plugin \
--data-dir $DATADIR"/data" \
--blocks-dir $DATADIR"/blocks" \
--config-dir $DATADIR"/config" \
--producer-name $BPACCOUNT \
--http-server-address 0.0.0.0:8888 \
--p2p-listen-endpoint 0.0.0.0:9010 \
--state-history-endpoint 0.0.0.0:8080 \
--access-control-allow-origin=* \
--contracts-console \
--http-validate-host=false \
--verbose-http-errors \
--enable-stale-production \
--trace-history \
--disable-replay-opts \
--chain-state-history \
--max-transaction-time=2000 \
--abi-serializer-max-time-ms=60000 \
--http-max-response-time-ms=8000 \
--chain-state-db-size-mb 8192 \
--chain-state-db-guard-size-mb 1024 \
--wasm-runtime=$EOSVM \
>> $DATADIR"/nodeos.log" 2>&1 & \
echo $! > $DATADIR"/eosd.pid"

sleep 3

cat .wallet.pw | cleos wallet unlock --password && cd custom && make boostrap-system

make setup-evm-contract

sleep 5

TIMESTAMP=$(cleos get block 3 |jq .timestamp)
TIMESTAMP="${TIMESTAMP:1:-1}"
TIMESTAMP=$(date -d$TIMESTAMP +%s)
TIMESTAMP=$(printf '0x%x\n' $TIMESTAMP)
BLOCK_ID=$(cleos get block 3 |jq .id)
BLOCK_ID="${BLOCK_ID:1:-1}"

echo "$( jq --arg TIMESTAMP "${TIMESTAMP}" '.timestamp = $TIMESTAMP' genesis.json )" > genesis.json
echo "$( jq --arg BLOCK_ID "${BLOCK_ID}" '.mixHash = $BLOCK_ID' genesis.json )" > genesis.json

rm -rf ./chain-data

eos-evm-node \
--chain-data ./chain-data \
--plugin block_conversion_plugin \
--plugin blockchain_plugin \
--nocolor 1 --verbosity=5 \
--ship-endpoint 127.0.0.1:8080 \
--engine-port 127.0.0.1:9090 \
--ship-core-account eosio.evm \
--genesis-json=./genesis.json \
>> eos-evm-node.log 2>&1 &

sleep 5

eos-evm-rpc \
--api-spec=eth,net --http-port=0.0.0.0:9981  \
--eos-evm-node=127.0.0.1:9090 \
--chaindata=./chain-data \
>> eos-rpc.log 2>&1 &

cd /app/custom/eos-evm-miner && node ./dist/index.js >> miner.log 2>&1 &

tail -f /dev/null
exec "$@"