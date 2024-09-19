module 0x1::BondingCurveFairLaunchTest {
    use std::signer;
    use aptos_framework::coin;
    use 0x1::BondingCurveFairLaunch;

    public fun test_initialize() {
        let creator = account::create_account();
        BondingCurveFairLaunch::initialize(&creator);

        let token = borrow_global<BondingCurveFairLaunch::Token>(account::address_of(creator));
        assert!(token.supply == 0, 101);
        assert!(token.price == 1, 102);
    }

    public fun test_buy() {
        let creator = account::create_account();
        BondingCurveFairLaunch::initialize(&creator);
        let initial_supply = 0;
        let amount_to_buy = 5;

        // Fund the creator account
        coin::mint(&creator, 20);

        // Buy tokens
        BondingCurveFairLaunch::buy(&creator, amount_to_buy);

        let token = borrow_global<BondingCurveFairLaunch::Token>(account::address_of(creator));
        assert!(token.supply == initial_supply + amount_to_buy, 103);
    }

    public fun test_buy_insufficient_funds() {
        let creator = account::create_account();
        BondingCurveFairLaunch::initialize(&creator);
        let amount_to_buy = 10;

        // Attempt to buy tokens without enough funds
        let result = BondingCurveFairLaunch::buy(&creator, amount_to_buy);
        
        // Ensure it fails with insufficient funds
        assert!(result == E_INSUFFICIENT_FUNDS, 104);
    }

    public fun test_calculate_price() {
        let price = BondingCurveFairLaunch::calculate_price(0);
        assert!(price == 1, 105); // Base price
        
        let price_after_one = BondingCurveFairLaunch::calculate_price(1);
        assert!(price_after_one == 2, 106); // Base price + slope * 1
    }
}
