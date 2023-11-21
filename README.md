<div align="center">
  <img src="docs/img/cover.jpeg">
</div>

```bash
starkli declare target/dev/bountive_Sbt.sierra.json --network=goerli-1 --compiler-version=2.1.0

# Declare the  contract to get the implementation's class hash.
starkli declare target/dev/bountive_sbt.sierra.json --network=goerli-1 --compiler-version=2.1.0
# Deploy the factory contract with the  class hash
starkli deploy $FACTORY_CLASS_HASH  $VAULT_CLASS_HASH $ADMIN_CONRTACT_ADDRESS
```
