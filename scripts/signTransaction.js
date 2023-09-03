const Web3 = require('web3');
const { ethers } = require('ethers');
const HDWalletProvider = require('@truffle/hdwallet-provider');

async function main() {
  try {
    const ethereumProviderEndpoint = 'http://127.0.0.1:50305';
    // const ethereumProviderEndpoint = 'https://api.evm.eosnetwork.com';
    const MNEMONIC = process.env.WALLET_MNEMONIC;

    const provider = new HDWalletProvider({
      mnemonic: MNEMONIC,
      providerOrUrl: ethereumProviderEndpoint,
    });

    const web3 = new Web3(provider);
    const transaction = await web3.eth.signTransaction({
      from: "0x748A1b651Fb70Dd8ac3660Aa422e9cdd666BbEF3",
      // gasPrice: "150000000000",
      // gas: "21000000",
      to: '0x3535353535353535353535353535353535353535',
      value: "1",
      data: "",
      // nonce: 7,
    })
    console.log('--- SIGNED TRANSACTION: ', transaction);
    const tx = await web3.eth.sendSignedTransaction(transaction.raw).on('receipt', console.log).on('error', console.log).on('sent', console.log);;
    console.log('-----  transaction: ', tx);

    // PUSH TRANSACTION USE ethers
    // const ethersProvider = new ethers.providers.JsonRpcProvider(ethereumProviderEndpoint);
    // const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, ethersProvider);

    // const tx = await wallet.sendTransaction({
    //   to: "3535353535353535353535353535353535353535",
    //   value: 1
    // });
    // const txResult = await tx.wait();
    // console.log('---- tx: ', tx, ' result', txResult);
  } catch(e) {
    console.log('---- error: ', e);
  }
}

main()