# EOS EVM Docker Utilities

EOS EVM Docker Utilities (EEDU) is comprehensive utilities for development in EOS EVM. That includes fully docker image, node management, helper scripts to setup development environment.

### Getting started

1. run EEDU docker

```bash
$ docker run -d -p 8888:8888 -p 9981:9981 quyvo/eedu:0.0.1-beta
```

2. Deposit token to EVM address

```bash
$ docker exec eedu-node cleos transfer eosio eosio.evm "1.0000 EOS" "0x748A1b651Fb70Dd8ac3660Aa422e9cdd666BbEF3"
executed transaction: 8d2087f6ff0ffe03aa6f2971835123b88bd42e5444be4c82347b4735325d4ea4  168 bytes  911 us
warning: transaction executed locally, but may not be confirmed by the network yet         ]
#   eosio.token <= eosio.token::transfer        {"from":"eosio","to":"eosio.evm","quantity":"1.0000 EOS","memo":"0x748A1b651Fb70Dd8ac3660Aa422e9cdd6...
#         eosio <= eosio.token::transfer        {"from":"eosio","to":"eosio.evm","quantity":"1.0000 EOS","memo":"0x748A1b651Fb70Dd8ac3660Aa422e9cdd6...
#     eosio.evm <= eosio.token::transfer        {"from":"eosio","to":"eosio.evm","quantity":"1.0000 EOS","memo":"0x748A1b651Fb70Dd8ac3660Aa422e9cdd6...
#     eosio.evm <= eosio.evm::pushtx            {"miner":"eosio.evm","rlptx":"f4808522ecb25c0082520894748a1b651fb70dd8ac3660aa422e9cdd666bbef3880dbd...
```

3. Check EVM balance

```bash
$ curl --location --request POST 'localhost:9981' --header 'Content-Type: application/json' --data-raw '{"method":"eth_getBalance","params":["0x748A1b651Fb70Dd8ac3660Aa422e9cdd666BbEF3","latest"],"id":0,"jsonrpc":"2.0"}'
{"id":0,"jsonrpc":"2.0","result":"0xdbd2fc137a30000"}
```