import process from 'process';
import {
  Asset,
  BASE_FEE,
  Horizon,
  Keypair,
  Networks,
  Operation,
  TransactionBuilder,
} from 'stellar-sdk';
import { inspect } from 'util';

const horizonUrl = 'https://horizon-testnet.stellar.org';
const friendbotUrl = 'https://friendbot.stellar.org';

/**
 * Key pairs for GIMMY and MARCO.
 *
 * These keypairs have been randomly generated and funded by the Stellar Testnet Friendbot.
 * They're not meant to be used if not for testing purposes on the Stellar Testnet.
 */
const keypairsRaw = {
  GIMMY: {
    publicKey: 'GAYMDXO4MSSCRBV6UQDPDKL3L3OX47LWNFXRLCA6M2LIL6NJBAEB4BI4',
    privateKey: 'SBXOJQ2353WV65DEGRGWRMF5S2EFNQAGURZ2Q2KGL4T2JSYGU5UDPVLK',
  },
  MARCO: {
    publicKey: 'GBLBEHE2WZ2YEBM32Y4ZF6BM2FG6DJLWKNKJAYN3OYHULVF2UT65EI2Y',
    privateKey: 'SAYPN6PIXQRPDTOO3TT6OGDGGI6VG7FKBNWCFOHRG5OJOU56WIIM5GLM',
  },
};

async function main({
  issuer,
  recipient,
  assetCode,
  tokenAmount,
}: {
  issuer: Keypair;
  recipient: Keypair;
  assetCode: string;
  tokenAmount: number;
}) {
  const server = new Horizon.Server(horizonUrl);
  const account = await server.loadAccount(issuer.publicKey());
  const asset = new Asset(assetCode, issuer.publicKey());

  const transaction = new TransactionBuilder(account, {
    fee: BASE_FEE,
    networkPassphrase: Networks.TESTNET,
  })
    .addOperation(
      Operation.changeTrust({
        asset: asset,
        // destination
        source: recipient.publicKey(),
      })
    )
    .addOperation(
      Operation.payment({
        destination: recipient.publicKey(),
        asset: asset,
        amount: `${tokenAmount / 1e7}`,
      })
    )
    .setTimeout(60 * 60)
    .build();

  console.log('Transaction ready to sign and submit');
  const trBeforeSign = transaction.toXDR();
  transaction.sign(issuer);
  const trAfterSign = transaction.toXDR();
  transaction.sign(recipient);
  const trAfterSign2 = transaction.toXDR();

  console.log(`TRANSACTIONS
============
Before sign:
${trBeforeSign}

After issuer sign:
${trAfterSign}

After recipient sign:
${trAfterSign2}
`);

  const res = await server.submitTransaction(transaction);
  console.log(`transaction hash:\n${res.hash}`);
}

const input: Parameters<typeof main>[0] = {
  issuer: Keypair.fromSecret(keypairsRaw.MARCO.privateKey),
  recipient: Keypair.fromSecret(keypairsRaw.GIMMY.privateKey),
  assetCode: 'MARK33',
  tokenAmount: 1000,
};

main(input).catch((error) => {
  console.error('Error:', inspect(error, false, null, true));
  process.exit(1);
});
