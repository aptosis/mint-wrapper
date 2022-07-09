/// Entry functions for the MintWrapper.

module MintWrapper::Entry {
    use MintWrapper::MintWrapper;

    /// Mints coins from the mint_wrapper on behalf of the mint_wrapper's authority.
    public(script) fun mint<CoinType>(
        authority: &signer,
        recipient: address,
        amount: u64
    ) {
        MintWrapper::mint<CoinType>(authority, recipient, amount);
    }

    /// Creates a new coin and mint_wrapper.
    /// The given account also becomes the MintWrapper's base.
    public(script) fun create_with_coin<CoinType>(
        account: &signer,
        name: vector<u8>,
        decimals: u64,
        hard_cap: u64
    ) {
        MintWrapper::create_with_coin<CoinType>(account, name, decimals, hard_cap)
    }

    /// Offers the owner.
    public(script) fun offer_owner<CoinType>(
        account: &signer,
        recipient: address
    ) {
        MintWrapper::offer_owner<CoinType>(account, recipient);
    }

    /// Creates a new minter with the given allowance, offering it.
    public(script) fun offer_minter<CoinType>(
        owner: &signer,
        destination: address,
        allowance: u64
    ) {
        MintWrapper::offer_minter<CoinType>(owner, destination, allowance);
    }

    /// Accepts the owner.
    public(script) fun accept_owner<CoinType>(
        recipient: &signer,
        base: address
    ) {
        MintWrapper::accept_owner<CoinType>(recipient, base);
    }

    /// Accepts the minter if possible.
    public(script) fun accept_minter<CoinType>(
        recipient: &signer,
        base: address
    ) {
        MintWrapper::accept_minter<CoinType>(recipient, base);
    }
}