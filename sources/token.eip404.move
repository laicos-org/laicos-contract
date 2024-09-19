module 0x1::DN404Mirror {

    use std::error;
    use std::signer;
    use std::event;
    use aptos_framework::coin;
    use aptos_framework::aptos_account;
    use aptos_framework::nft;

    // Error codes
    const E_SENDER_NOT_BASE: u64 = 1;
    const E_TOKEN_DOES_NOT_EXIST: u64 = 2;
    const E_TRANSFER_TO_ZERO_ADDRESS: u64 = 3;
    const E_APPROVE_CALLER_NOT_OWNER: u64 = 4;
    const E_CALLER_NOT_APPROVED: u64 = 5;

    // Events
    struct TransferEvent has key, store {
        from: address,
        to: address,
        token_id: u64,
    }

    struct ApprovalEvent has key, store {
        owner: address,
        approved: address,
        token_id: u64,
    }

    // Token owner resource
    struct Token has store {
        id: u64,
        owner: address,
    }

    // Store for approved operators
    struct Approval has store {
        approved: address,
    }

    public fun transfer_from(
        from: &signer,
        to: address,
        token_id: u64
    ) acquires Token {
        let sender = signer::address_of(from);
        let token = borrow_global_mut<Token>(token_id);

        // Check if the sender is either the token owner or has been approved
        if (token.owner != sender && !is_approved(sender, token_id)) {
            abort E_CALLER_NOT_APPROVED;
        }

        // Ensure transfer to non-zero address
        if (to == @0x0) {
            abort E_TRANSFER_TO_ZERO_ADDRESS;
        }

        // Transfer the token
        token.owner = to;

        // Emit transfer event
        event::emit_event<TransferEvent>(
            &TransferEvent { from: token.owner, to, token_id }
        );
    }

    public fun approve(
        owner: &signer,
        approved: address,
        token_id: u64
    ) acquires Approval {
        let sender = signer::address_of(owner);
        let token = borrow_global<Token>(token_id);

        if (token.owner != sender) {
            abort E_APPROVE_CALLER_NOT_OWNER;
        }

        move_to(approved, Approval { approved });

        // Emit approval event
        event::emit_event<ApprovalEvent>(
            &ApprovalEvent { owner: sender, approved, token_id }
        );
    }

    public fun is_approved(
        address: address,
        token_id: u64
    ): bool acquires Approval {
        let approval = borrow_global<Approval>(token_id);
        approval.approved == address
    }

    // Mint function to create a new token
    public fun mint(
        creator: &signer,
        token_id: u64,
        to: address
    ) {
        let token = Token { id: token_id, owner: to };
        move_to(creator, token);
    }
}
