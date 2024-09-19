module 0x1::BondingCurveFairLaunch {
    use std::signer;
    use std::coin;
    use std::event;

    // Error codes
    const E_INSUFFICIENT_FUNDS: u64 = 1;
    const E_INVALID_AMOUNT: u64 = 2;

    // Token data structure
    struct Token has store {
        supply: u64,
        price: u64,
    }

    struct PurchaseEvent has key, store {
        buyer: address,
        amount: u64,
        total_price: u64,
    }

    public fun initialize(creator: &signer) acquires Token {
        move_to(creator, Token { supply: 0, price: 1 }); // Starting price 1 unit of currency
    }

    public fun buy(creator: &signer, amount: u64) acquires Token {
        let token = borrow_global_mut<Token>(signer::address_of(creator));

        // Calculate the price based on the bonding curve
        let total_price = calculate_price(token.supply + amount);
        assert!(total_price > 0, E_INVALID_AMOUNT);

        // Ensure the buyer has enough funds
        coin::transfer(creator, total_price);

        // Update token supply and emit event
        token.supply += amount;
        event::emit_event<PurchaseEvent>(
            &PurchaseEvent {
                buyer: signer::address_of(creator),
                amount,
                total_price,
            }
        );
    }

    public fun calculate_price(supply: u64): u64 {
        // Simple linear bonding curve: price = base_price + (supply * slope)
        let base_price = 1; // Starting price
        let slope = 1; // Price increase per token
        base_price + (slope * supply)
    }
}
