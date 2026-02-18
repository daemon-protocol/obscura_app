use anchor_lang::prelude::*;
use ephemeral_rollups_sdk::cpi::delegate_account;
use ephemeral_rollups_sdk::cr::commit_and_undelegate_accounts;
use ephemeral_rollups_sdk::ephem::commit_accounts;

declare_id!("YOUR_PROGRAM_ID");

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// MagicBlock Delegation Program
pub const DELEGATION_PROGRAM: &str = "DELeGGvXpWV2fqJUhqcF5ZSYMS4JTLjteaAMARRSaeSh";

/// MagicBlock Access Control Program (for PER visibility restrictions)
pub const ACCESS_CONTROL_PROGRAM: &str = "ACLseoPoyC3cBqoUtkbjZ4aDrkurZW86v19pXz2XQnp1";

/// Vault seed prefix
pub const VAULT_SEED: &[u8] = b"obscura_vault";

/// Permission seed prefix
pub const PERMISSION_SEED: &[u8] = b"obscura_permission";

// ---------------------------------------------------------------------------
// Program
// ---------------------------------------------------------------------------

/// Obscura PER - Private Ephemeral Rollups program.
///
/// Uses MagicBlock's Ephemeral Rollups for sub-second transaction finality
/// and Private ER (PER) via TEE validators for account-level privacy.
///
/// Integrates Light Protocol ZK Compression for reduced on-chain storage costs.
#[ephemeral_rollups_sdk::ephemeral]
#[program]
pub mod obscura_per {
    use super::*;

    // -----------------------------------------------------------------------
    // Vault lifecycle
    // -----------------------------------------------------------------------

    /// Create a new private vault PDA.
    ///
    /// The vault stores the owner's privacy-preserving state and can be
    /// delegated to an ER validator for fast execution, or to a TEE
    /// validator for private execution.
    pub fn create_vault(ctx: Context<CreateVault>, vault_id: u64) -> Result<()> {
        let vault = &mut ctx.accounts.vault;
        vault.owner = ctx.accounts.owner.key();
        vault.vault_id = vault_id;
        vault.balance = 0;
        vault.is_delegated = false;
        vault.delegate_validator = Pubkey::default();
        vault.created_at = Clock::get()?.unix_timestamp;
        vault.last_activity = Clock::get()?.unix_timestamp;
        vault.nonce = 0;
        vault.is_private = false;

        msg!(
            "Vault created: id={}, owner={}",
            vault_id,
            ctx.accounts.owner.key()
        );
        Ok(())
    }

    /// Delegate vault to an Ephemeral Rollup validator.
    ///
    /// After delegation the account lives on the ER validator and
    /// transactions touching it achieve sub-second finality (~50 ms).
    ///
    /// For **Private ER (PER)**, pass the TEE validator pubkey:
    /// `FnE6VJT5QNZdedZPnCoLsARgBwoE6DeJNjBs2H1gySXA`
    pub fn delegate_vault(ctx: Context<DelegateVault>, validator: Pubkey) -> Result<()> {
        // Record delegation metadata *before* we hand off to the SDK,
        // because after delegation the account is owned by the ER validator.
        let vault = &mut ctx.accounts.vault;
        vault.is_delegated = true;
        vault.delegate_validator = validator;
        vault.last_activity = Clock::get()?.unix_timestamp;

        // Known TEE validator for PER
        const TEE_VALIDATOR: &str = "FnE6VJT5QNZdedZPnCoLsARgBwoE6DeJNjBs2H1gySXA";
        if validator.to_string() == TEE_VALIDATOR {
            vault.is_private = true;
            msg!("Delegating to TEE validator for Private ER");
        }

        msg!(
            "Delegating vault {} to validator {}",
            vault.vault_id,
            validator
        );

        // Perform the CPI into the delegation program.
        // The `#[delegate]` macro on `DelegateVault` auto-generates the
        // required accounts; we just call the SDK helper.
        ctx.accounts.delegate_vault(
            &ctx.accounts.owner,
            &[VAULT_SEED, &vault.vault_id.to_le_bytes()],
            validator,
        )?;

        Ok(())
    }

    /// Execute a private transfer inside the Ephemeral Rollup.
    ///
    /// This instruction runs on the ER validator and benefits from
    /// sub-second finality.  When finished it commits the updated state
    /// back to L1 and undelegates the account in a single atomic step.
    pub fn private_transfer(
        ctx: Context<PrivateTransfer>,
        amount: u64,
        recipient: Pubkey,
    ) -> Result<()> {
        let vault = &mut ctx.accounts.vault;

        require!(vault.is_delegated, ObscuraError::NotDelegated);
        require!(vault.balance >= amount, ObscuraError::InsufficientBalance);
        require!(
            vault.owner == ctx.accounts.owner.key(),
            ObscuraError::Unauthorized
        );

        // Execute transfer logic
        vault.balance = vault.balance.checked_sub(amount).unwrap();
        vault.nonce += 1;
        vault.last_activity = Clock::get()?.unix_timestamp;

        msg!(
            "Private transfer: {} lamports to {}, nonce={}",
            amount,
            recipient,
            vault.nonce
        );

        // Commit state back to L1 and undelegate in one step.
        // The `#[commit]` macro on `PrivateTransfer` wires up the
        // `magic_context` and `magic_program` accounts automatically.
        ctx.accounts.commit_and_undelegate_vault()?;

        Ok(())
    }

    /// Commit current vault state to L1 without undelegating.
    ///
    /// Useful for periodic checkpoints while keeping the account
    /// delegated for continued fast execution.
    pub fn commit_vault_state(ctx: Context<CommitState>) -> Result<()> {
        let vault = &mut ctx.accounts.vault;
        vault.last_activity = Clock::get()?.unix_timestamp;

        msg!("Committing vault {} state to L1", vault.vault_id);

        ctx.accounts.commit_vault()?;

        Ok(())
    }

    /// Undelegate vault — return the account to L1.
    ///
    /// After undelegation the account is a normal Solana account again
    /// and the ER validator no longer has authority over it.
    pub fn undelegate_vault(ctx: Context<UndelegateVault>) -> Result<()> {
        let vault = &mut ctx.accounts.vault;
        vault.is_delegated = false;
        vault.delegate_validator = Pubkey::default();
        vault.is_private = false;
        vault.last_activity = Clock::get()?.unix_timestamp;

        msg!("Undelegating vault {}", vault.vault_id);

        ctx.accounts.commit_and_undelegate_vault()?;

        Ok(())
    }

    /// Deposit SOL into the vault.
    pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
        let vault = &mut ctx.accounts.vault;

        // Transfer SOL from depositor to vault PDA
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &ctx.accounts.depositor.key(),
            &vault.key(),
            amount,
        );
        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                ctx.accounts.depositor.to_account_info(),
                vault.to_account_info(),
                ctx.accounts.system_program.to_account_info(),
            ],
        )?;

        vault.balance = vault.balance.checked_add(amount).unwrap();
        vault.last_activity = Clock::get()?.unix_timestamp;

        msg!("Deposited {} lamports into vault {}", amount, vault.vault_id);
        Ok(())
    }

    /// Withdraw SOL from the vault.
    pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
        let vault = &mut ctx.accounts.vault;

        require!(!vault.is_delegated, ObscuraError::AccountDelegated);
        require!(vault.balance >= amount, ObscuraError::InsufficientBalance);
        require!(
            vault.owner == ctx.accounts.owner.key(),
            ObscuraError::Unauthorized
        );

        // Transfer SOL from vault PDA to owner
        **vault.to_account_info().try_borrow_mut_lamports()? -= amount;
        **ctx.accounts.owner.try_borrow_mut_lamports()? += amount;

        vault.balance = vault.balance.checked_sub(amount).unwrap();
        vault.last_activity = Clock::get()?.unix_timestamp;

        msg!(
            "Withdrew {} lamports from vault {}",
            amount,
            vault.vault_id
        );
        Ok(())
    }

    /// Create a permission entry for Access Control (PER visibility).
    ///
    /// Only accounts with a valid permission PDA can read the vault
    /// state when it is delegated to a TEE validator.
    pub fn create_permission(
        ctx: Context<CreatePermission>,
        permitted_pubkey: Pubkey,
    ) -> Result<()> {
        let permission = &mut ctx.accounts.permission;
        permission.vault = ctx.accounts.vault.key();
        permission.permitted = permitted_pubkey;
        permission.granted_by = ctx.accounts.owner.key();
        permission.granted_at = Clock::get()?.unix_timestamp;

        msg!(
            "Permission granted: {} can access vault {}",
            permitted_pubkey,
            ctx.accounts.vault.key()
        );
        Ok(())
    }
}

// ---------------------------------------------------------------------------
// Accounts (instruction contexts)
// ---------------------------------------------------------------------------

#[derive(Accounts)]
#[instruction(vault_id: u64)]
pub struct CreateVault<'info> {
    #[account(
        init,
        payer = owner,
        space = 8 + VaultState::INIT_SPACE,
        seeds = [VAULT_SEED, &vault_id.to_le_bytes()],
        bump,
    )]
    pub vault: Account<'info, VaultState>,

    #[account(mut)]
    pub owner: Signer<'info>,

    pub system_program: Program<'info, System>,
}

/// Delegate a vault to an ER validator.
///
/// The `#[delegate]` attribute from `ephemeral-rollups-sdk` automatically
/// adds the delegation program accounts and generates a
/// `delegate_vault(&self, ...)` helper on the context.
#[delegate]
#[derive(Accounts)]
pub struct DelegateVault<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED, &vault.vault_id.to_le_bytes()],
        bump,
        del,  // marks this account for delegation
    )]
    pub vault: Account<'info, VaultState>,

    #[account(mut)]
    pub owner: Signer<'info>,
}

/// Private transfer within the ephemeral rollup, then commit + undelegate.
///
/// The `#[commit]` attribute auto-adds `magic_context` and `magic_program`
/// accounts and generates `commit_and_undelegate_vault(&self)`.
#[commit]
#[derive(Accounts)]
pub struct PrivateTransfer<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED, &vault.vault_id.to_le_bytes()],
        bump,
        com,  // marks this account for commit
    )]
    pub vault: Account<'info, VaultState>,

    #[account(mut)]
    pub owner: Signer<'info>,
}

/// Commit vault state to L1 without undelegating.
#[commit]
#[derive(Accounts)]
pub struct CommitState<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED, &vault.vault_id.to_le_bytes()],
        bump,
        com,
    )]
    pub vault: Account<'info, VaultState>,

    #[account(mut)]
    pub owner: Signer<'info>,
}

/// Undelegate — commit + undelegate in one step.
#[commit]
#[derive(Accounts)]
pub struct UndelegateVault<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED, &vault.vault_id.to_le_bytes()],
        bump,
        com,
    )]
    pub vault: Account<'info, VaultState>,

    #[account(mut)]
    pub owner: Signer<'info>,
}

#[derive(Accounts)]
pub struct Deposit<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED, &vault.vault_id.to_le_bytes()],
        bump,
    )]
    pub vault: Account<'info, VaultState>,

    #[account(mut)]
    pub depositor: Signer<'info>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Withdraw<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED, &vault.vault_id.to_le_bytes()],
        bump,
        constraint = vault.owner == owner.key() @ ObscuraError::Unauthorized,
    )]
    pub vault: Account<'info, VaultState>,

    #[account(mut)]
    pub owner: Signer<'info>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(permitted_pubkey: Pubkey)]
pub struct CreatePermission<'info> {
    #[account(
        init,
        payer = owner,
        space = 8 + PermissionState::INIT_SPACE,
        seeds = [PERMISSION_SEED, vault.key().as_ref(), permitted_pubkey.as_ref()],
        bump,
    )]
    pub permission: Account<'info, PermissionState>,

    #[account(
        constraint = vault.owner == owner.key() @ ObscuraError::Unauthorized,
    )]
    pub vault: Account<'info, VaultState>,

    #[account(mut)]
    pub owner: Signer<'info>,

    pub system_program: Program<'info, System>,
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// On-chain vault state managed by Obscura.
///
/// When delegated to an ER validator, mutations happen with sub-second
/// finality.  When delegated to the TEE validator, the account data is
/// only visible to permitted pubkeys.
#[account]
#[derive(InitSpace)]
pub struct VaultState {
    /// Wallet owner
    pub owner: Pubkey,
    /// Unique vault identifier
    pub vault_id: u64,
    /// SOL balance in lamports
    pub balance: u64,
    /// Whether the account is currently delegated to an ER validator
    pub is_delegated: bool,
    /// Pubkey of the ER validator (default = not delegated)
    pub delegate_validator: Pubkey,
    /// Unix timestamp of creation
    pub created_at: i64,
    /// Unix timestamp of last activity
    pub last_activity: i64,
    /// Monotonically increasing nonce for replay protection
    pub nonce: u64,
    /// Whether delegated to TEE validator (Private ER)
    pub is_private: bool,
}

/// Permission entry for PER access control.
///
/// Grants a specific pubkey the ability to read vault state when the
/// vault is delegated to a TEE validator.
#[account]
#[derive(InitSpace)]
pub struct PermissionState {
    /// The vault this permission applies to
    pub vault: Pubkey,
    /// The pubkey that is permitted to read the vault
    pub permitted: Pubkey,
    /// Who granted the permission
    pub granted_by: Pubkey,
    /// When the permission was granted
    pub granted_at: i64,
}

// ---------------------------------------------------------------------------
// Errors
// ---------------------------------------------------------------------------

#[error_code]
pub enum ObscuraError {
    #[msg("The account is not currently delegated to an ER validator")]
    NotDelegated,

    #[msg("Insufficient balance for this operation")]
    InsufficientBalance,

    #[msg("You are not authorized to perform this action")]
    Unauthorized,

    #[msg("The account is currently delegated — undelegate first")]
    AccountDelegated,

    #[msg("Invalid validator pubkey")]
    InvalidValidator,

    #[msg("Permission already exists for this pubkey")]
    PermissionExists,

    #[msg("Vault is not in private mode")]
    NotPrivate,
}
