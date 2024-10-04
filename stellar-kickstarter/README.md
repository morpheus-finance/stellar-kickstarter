# Hey

- [diagrams](./diagrams): Contains diagrams for the project.
- [index.ts](./index.ts): Simple script to do some little test on Stellar.

## Test script

Change the `const input` variable to test the script at will.

```typescript

Run it with:

```bash
npm run start
```

You can comment out these two lines in the index.ts file

```typescript
  const res = await server.submitTransaction(transaction);
  console.log(`transaction hash:\n${res.hash}`);
```

then take the XDR of the transaction at the step you wish (before issuer signs,
before receiver signs, etc) and use it in [simple
signer](https://github.com/bigger-tech/simple-stellar-signer) to try to sign it
(you can import a wallet by pasting the private key value found at the beginning
of the file).
