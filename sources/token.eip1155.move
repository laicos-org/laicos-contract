module LaicosNFT1155 {
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_std::option;
    use std::vector;
    
    struct MultiToken {
        id: u64,
        balances: table::Table<address, u64>,
        metadata_uri: vector<u8>,
    }

    struct MultiTokenEvent has store {
        mint_event: event::EventHandle<(address, u64, u64)>, // (recipient, id, amount)
        transfer_event: event::EventHandle<(address, address, u64, u64)>, // (from, to, id, amount)
    }

    public fun init_collection(
        account: &signer
    ) {
        let collection_address = signer::address_of(account);
        if (!exists<MultiTokenEvent>(collection_address)) {
            move_to(account, MultiTokenEvent {
                mint_event: event::new_event_handle<(address, u64, u64)>(account),
                transfer_event: event::new_event_handle<(address, address, u64, u64)>(account),
            });
        }
    }

    public fun mint_multi_token(
        account: &signer,
        recipient: address,
        id: u64,
        amount: u64,
        metadata_uri: vector<u8>
    ) {
        let collection_address = signer::address_of(account);
        assert!(exists<MultiTokenEvent>(collection_address), 1);
        
        // Mint multi-token and update balances
        if (!exists<MultiToken>(collection_address)) {
            move_to(account, MultiToken { 
                id, 
                balances: table::new<address, u64>(), 
                metadata_uri 
            });
        }
        let multi_token = borrow_global_mut<MultiToken>(collection_address);
        table::add(&mut multi_token.balances, recipient, amount);
        
        let collection_resource = borrow_global_mut<MultiTokenEvent>(collection_address);
        event::emit_event(&mut collection_resource.mint_event, (recipient, id, amount));
    }

    public fun transfer_multi_token(
        sender: &signer,
        recipient: address,
        id: u64,
        amount: u64
    ) {
        let sender_address = signer::address_of(sender);
        let multi_token = borrow_global_mut<MultiToken>(sender_address);

        let sender_balance = table::borrow_mut(&mut multi_token.balances, sender_address);
        assert!(*sender_balance >= amount, 2);
        
        // Deduct amount from sender and add to recipient
        *sender_balance = *sender_balance - amount;
        let recipient_balance = table::borrow_mut(&mut multi_token.balances, recipient);
        *recipient_balance = *recipient_balance + amount;

        let collection_resource = borrow_global_mut<MultiTokenEvent>(sender_address);
        event::emit_event(&mut collection_resource.transfer_event, (sender_address, recipient, id, amount));
    }

    public fun get_balance(owner: address, id: u64): u64 {
        let multi_token = borrow_global<MultiToken>(id);
        table::borrow(&multi_token.balances, owner)
    }
}
