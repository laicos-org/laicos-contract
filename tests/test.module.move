module 0x1::DN404MirrorTest {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_framework::token;
    use 0x1::DN404Mirror;

    /// This function tests minting a token.
    public fun test_mint() {
        let creator = account::create_account();
        let recipient = account::create_account();
        let token_id: u64 = 100;

        // Mint the token from creator to recipient
        DN404Mirror::mint(&creator, token_id, account::address_of(recipient));

        // Assert that the token has the correct owner
        let token = borrow_global<DN404Mirror::Token>(token_id);
        assert!(token.owner == account::address_of(recipient), 101);
    }

    /// This function tests transferring a token.
    public fun test_transfer() {
        let creator = account::create_account();
        let recipient = account::create_account();
        let new_owner = account::create_account();
        let token_id: u64 = 200;

        // Mint a token first
        DN404Mirror::mint(&creator, token_id, account::address_of(recipient));

        // Transfer the token from recipient to new_owner
        DN404Mirror::transfer_from(
            &recipient, 
            account::address_of(new_owner), 
            token_id
        );

        // Assert that the token has been transferred to new_owner
        let token = borrow_global<DN404Mirror::Token>(token_id);
        assert!(token.owner == account::address_of(new_owner), 102);
    }

    /// This function tests approval of an operator.
    public fun test_approve() {
        let creator = account::create_account();
        let owner = account::create_account();
        let operator = account::create_account();
        let token_id: u64 = 300;

        // Mint the token
        DN404Mirror::mint(&creator, token_id, account::address_of(owner));

        // Approve an operator
        DN404Mirror::approve(&owner, account::address_of(operator), token_id);

        // Check that the operator is approved
        let is_approved = DN404Mirror::is_approved(account::address_of(operator), token_id);
        assert!(is_approved == true, 103);
    }

    /// This function tests the failure of transferring by an unapproved operator.
    public fun test_transfer_fail_without_approval() {
        let creator = account::create_account();
        let owner = account::create_account();
        let unauthorized_user = account::create_account();
        let token_id: u64 = 400;

        // Mint the token
        DN404Mirror::mint(&creator, token_id, account::address_of(owner));

        // Try to transfer the token by an unauthorized user
        let result = DN404Mirror::transfer_from(
            &unauthorized_user,
            account::address_of(owner),
            token_id
        );

        // Ensure the transaction fails with the proper error code
        assert!(result == E_CALLER_NOT_APPROVED, 104);
    }

    /// This function tests transfer to zero address failure.
    public fun test_transfer_fail_zero_address() {
        let creator = account::create_account();
        let owner = account::create_account();
        let token_id: u64 = 500;

        // Mint the token
        DN404Mirror::mint(&creator, token_id, account::address_of(owner));

        // Attempt transfer to zero address (0x0)
        let result = DN404Mirror::transfer_from(
            &owner,
            @0x0,
            token_id
        );

        // Ensure the transaction fails with the proper error code
        assert!(result == E_TRANSFER_TO_ZERO_ADDRESS, 105);
    }
}
