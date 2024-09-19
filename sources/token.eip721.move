module LaicosNFT721 {
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_std::option;
    use std::vector;
    
    struct NFT<phantom T> has copy, drop, store {
        id: u64,
        owner: address,
        metadata_uri: vector<u8>,
    }

    struct NFTEvent has store {
        mint_event: event::EventHandle<u64>,
        transfer_event: event::EventHandle<(address, address, u64)>,
    }

    public fun init_collection(
        account: &signer
    ) {
        let collection_address = signer::address_of(account);
        if (!exists<NFTEvent>(collection_address)) {
            move_to(account, NFTEvent {
                mint_event: event::new_event_handle<u64>(account),
                transfer_event: event::new_event_handle<(address, address, u64)>(account),
            });
        }
    }

    public fun mint_nft<T>(
        account: &signer,
        recipient: address,
        id: u64,
        metadata_uri: vector<u8>
    ) {
        let collection_address = signer::address_of(account);
        assert!(exists<NFTEvent>(collection_address), 1);
        
        // Mint the NFT
        let nft = NFT<T> { id, owner: recipient, metadata_uri };
        let collection_resource = borrow_global_mut<NFTEvent>(collection_address);
        event::emit_event(&mut collection_resource.mint_event, id);
        move_to(&signer::signer_of(recipient), nft);
    }

    public fun transfer_nft<T>(
        sender: &signer,
        recipient: address,
        id: u64
    ) {
        let nft = withdraw<NFT<T>>(signer::address_of(sender));
        assert!(nft.id == id, 2); // Ensure correct token is transferred

        // Transfer ownership
        let recipient_signer = signer::signer_of(recipient);
        move_to(&recipient_signer, nft);

        let collection_address = signer::address_of(sender);
        let collection_resource = borrow_global_mut<NFTEvent>(collection_address);
        event::emit_event(&mut collection_resource.transfer_event, (signer::address_of(sender), recipient, id));
    }

    public fun get_owner<T>(id: u64): address {
        let nft = borrow_global<NFT<T>>(id);
        nft.owner
    }
}
