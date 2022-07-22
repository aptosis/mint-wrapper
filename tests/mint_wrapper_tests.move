module mint_wrapper::mint_wrapper_tests {
    use mint_wrapper::mint_wrapper;
    struct A { }

    #[test(
        mint_wrapper = @mint_wrapper,
    )]
    public entry fun test_create(
        mint_wrapper: signer,
    ) {
        mint_wrapper::create_with_coin<A>(
            &mint_wrapper,
            b"my name",
            6,
            100000,
        );
    }
}