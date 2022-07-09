# Aptosis Mint Wrapper

Allows delegating the minting of coins to multiple addresses.

A `MintWrapper` can be created for any coin.

There are two roles one can possess with a `MintWrapper`:

- **Owners**, which can create and delete Minters
- **Minters**, which can mint coins to any address

## Installation

To use MintWrapper in your code, add the following to the `[addresses]` section of your `Move.toml`:

```toml
[addresses]
MintWrapper = "0x8f6ce396d6c4b9c7c992f018e94df010ec5c50835d1c83186c023bfa22df638c"
```

## License

Apache-2.0
