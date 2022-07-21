/// Entry functions for the mint_wrapper.

module mint_wrapper::mw_entry {
    use mint_wrapper::mint_wrapper;

    /// Mints coins from the mint_wrapper on behalf of the mint_wrapper's authority.
    public entry fun mint<CoinType>(
        authority: &signer,
        recipient: address,
        amount: u64
    ) {
        mint_wrapper::mint<CoinType>(authority, recipient, amount);
    }

    /// Creates a new coin and mint_wrapper.
    /// The given account also becomes the mint_wrapper's base.
    public entry fun create_with_coin<CoinType>(
        account: &signer,
        name: vector<u8>,
        decimals: u64,
        hard_cap: u64
    ) {
        mint_wrapper::create_with_coin<CoinType>(account, name, decimals, hard_cap)
    }

    /// Offers the owner.
    public entry fun offer_owner<CoinType>(
        account: &signer,
        recipient: address
    ) {
        mint_wrapper::offer_owner<CoinType>(account, recipient);
    }

    /// Creates a new minter with the given allowance, offering it.
    public entry fun offer_minter<CoinType>(
        owner: &signer,
        destination: address,
        allowance: u64
    ) {
        mint_wrapper::offer_minter<CoinType>(owner, destination, allowance);
    }

    /// Accepts the owner.
    public entry fun accept_owner<CoinType>(
        recipient: &signer,
        base: address
    ) {
        mint_wrapper::accept_owner<CoinType>(recipient, base);
    }

    /// Accepts the minter if possible.
    public entry fun accept_minter<CoinType>(
        recipient: &signer,
        base: address
    ) {
        mint_wrapper::accept_minter<CoinType>(recipient, base);
    }
}