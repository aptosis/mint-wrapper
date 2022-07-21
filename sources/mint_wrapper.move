/// Allows delegating the minting of coins to multiple addresses.
///
/// A `MintWrapper` can be created for any coin.
///
/// There are two roles one can possess with a `MintWrapper`:
/// - **Owners**, which can create and delete Minters
/// - **Minters**, which can mint coins to any address

module mint_wrapper::mint_wrapper {
    use std::string;
    use std::errors;
    use std::offer;
    use std::signer;
    use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability};
    use aptos_framework::type_info;
    use aptos_framework::table::{Self, Table};

    /// Must be the owner of the mint wrapper.
    const ENOT_OWNER: u64 = 1;

    /// You do not have the minter privilege for this mint wrapper.
    const ENOT_MINTER: u64 = 2;

    /// Allowance exceeded.
    const EINSUFFICIENT_ALLOWANCE: u64 = 3;

    /// Holds the mint/burn capabilities.
    struct MintWrapper<phantom CoinType> has key {
        /// The capability to mint `CoinType`.
        mint_capability: MintCapability<CoinType>,
        /// The capability to burn `CoinType`.
        burn_capability: BurnCapability<CoinType>,
        /// Optional hard cap of the amount of coins that may be issued.
        hard_cap: u64,
    }

    /// Having this permission allows one to create and delete minters.
    struct Owner<phantom CoinType> has key, store {
        /// Where the mint wrapper is stored.
        base: address
    }

    /// Capability to mint at the mint_wrapper of the given coin.
    struct Minter<phantom CoinType> has key, store {
        /// Mint capability for this Minter.
        mint_capability: MintCapability<CoinType>,
        /// Maximum amount that this [Minter] can mint.
        allowance: u64
    }

    /// Container for holding minters which are to be transferred to someone.
    struct MinterOffers<phantom CoinType> has key {
        /// Minters being offered.
        offers: Table<address, Minter<CoinType>>,
    }

    /// Gets the address of a Coin.
    fun get_coin_address<CoinType>(): address {
        type_info::account_address(&type_info::type_of<CoinType>())
    }

    /// Creates a new `MintWrapper`.
    /// 
    /// # Arguments
    /// - `base` -- the owner of the mint wrapper.
    /// - `mint_capability` -- the mint capability of the `Coin`.
    /// - `burn_capability` -- the burn capability of the `Coin`.
    /// - `hard_cap` -- the maximum amount of coins that can be issues.
    public fun create<CoinType>(
        base: &signer,
        mint_capability: MintCapability<CoinType>,
        burn_capability: BurnCapability<CoinType>,
        hard_cap: u64
    ): Owner<CoinType> {
        move_to(base, MintWrapper<CoinType> {
            mint_capability,
            burn_capability,
            hard_cap,
        });
        move_to(base, MinterOffers<CoinType> {
            offers: table::new(),
        });
        Owner<CoinType> {
            base: signer::address_of(base)
        }
    }

    /// Mints coins from a mint_wrapper on behalf of the mint_wrapper's authority.
    public fun mint_with_capability<CoinType>(
        minter: &mut Minter<CoinType>,
        amount: u64
    ): Coin<CoinType> {
        assert!(
            minter.allowance >= amount,
            errors::limit_exceeded(EINSUFFICIENT_ALLOWANCE)
        );
        minter.allowance = minter.allowance - amount;
        coin::mint<CoinType>(amount, &minter.mint_capability)
    }

    /// Creates a new minter with the given allowance.
    public fun create_minter<CoinType>(
        owner: &signer,
        allowance: u64
    ): Minter<CoinType> acquires Owner, MintWrapper {
        let owner_cap = borrow_global<Owner<CoinType>>(signer::address_of(owner));
        create_minter_with_owner(allowance, owner_cap)
    }

    /// Creates a new Minter.
    public fun create_minter_with_owner<CoinType>(
        allowance: u64,
        owner: &Owner<CoinType>
    ): Minter<CoinType> acquires MintWrapper {
        let mint_capability = borrow_global<MintWrapper<CoinType>>(owner.base).mint_capability;
        Minter<CoinType> {
            mint_capability,
            allowance
        }
    }

    /// Mints coins from the mint_wrapper on behalf of the mint_wrapper's authority.
    public fun mint<CoinType>(
        authority: &signer,
        recipient: address,
        amount: u64
    ) acquires Minter {
        let authority_addr = signer::address_of(authority);
        assert!(
            exists<Minter<CoinType>>(authority_addr),
            errors::requires_role(ENOT_MINTER)
        );
        let mint_wrapper_minter = borrow_global_mut<Minter<CoinType>>(authority_addr);
        let coin = mint_with_capability(mint_wrapper_minter, amount);
        coin::deposit<CoinType>(recipient, coin);
    }

    /// Creates a new coin and mint_wrapper.
    /// The given account also becomes the MintWrapper's base.
    public fun create_with_coin<CoinType>(
        account: &signer,
        name: vector<u8>,
        decimals: u64,
        hard_cap: u64
    ) {
        let (mint_capability, burn_capability) = coin::initialize<CoinType>(
            account,
            string::utf8(name),
            string::utf8(type_info::struct_name(&type_info::type_of<CoinType>())),
            decimals,
            true
        );
        move_to(account, create(account, mint_capability, burn_capability, hard_cap));
    }

    /// Offers the owner.
    public fun offer_owner<CoinType>(
        account: &signer,
        recipient: address
    ) acquires Owner {
        offer::create<Owner<CoinType>>(
            account,
            move_from<Owner<CoinType>>(signer::address_of(account)),
            recipient
        );
    }

    /// Accepts the owner.
    public fun accept_owner<CoinType>(
        recipient: &signer,
        base: address
    ) {
        move_to(recipient, offer::redeem<Owner<CoinType>>(recipient, base));
    }

    /// Creates a new minter with the given allowance, offering it.
    public fun offer_minter<CoinType>(
        owner: &signer,
        destination: address,
        allowance: u64
    ) acquires MinterOffers, Owner, MintWrapper {
        assert!(
            exists<Owner<CoinType>>(signer::address_of(owner)),
            errors::requires_role(ENOT_OWNER)
        );
        let owner_cap = borrow_global<Owner<CoinType>>(signer::address_of(owner));
        let minter = create_minter_with_owner(allowance, owner_cap);
        let offers = borrow_global_mut<MinterOffers<CoinType>>(owner_cap.base);
        table::add(&mut offers.offers, destination, minter);
    }

    /// Accepts the [Minter] for the `CoinType`.
    public fun accept_minter<CoinType>(
        recipient: &signer,
        base: address
    ) acquires MinterOffers {
        let offers = borrow_global_mut<MinterOffers<CoinType>>(base);
        let minter = table::remove<address, Minter<CoinType>>(&mut offers.offers, signer::address_of(recipient));
        move_to(recipient, minter);
    }
}
