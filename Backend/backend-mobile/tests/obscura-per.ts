import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { PublicKey, Keypair, SystemProgram } from "@solana/web3.js";
import { expect } from "chai";
import * as dotenv from "dotenv";

dotenv.config();

// Import the generated IDL type  (after `anchor build`)
// import { ObscuraPer } from "../target/types/obscura_per";

describe("obscura-per", () => {
  // -----------------------------------------------------------------------
  // Setup
  // -----------------------------------------------------------------------

  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  // After `anchor build` and IDL generation, uncomment:
  // const program = anchor.workspace.ObscuraPer as Program<ObscuraPer>;
  const programId = new PublicKey(
    process.env.PROGRAM_ID || "YOUR_PROGRAM_ID"
  );

  const owner = provider.wallet;
  const vaultId = new anchor.BN(1);

  // MagicBlock constants
  const DELEGATION_PROGRAM = new PublicKey(
    "DELeGGvXpWV2fqJUhqcF5ZSYMS4JTLjteaAMARRSaeSh"
  );

  // Devnet validators from official MagicBlock docs
  const VALIDATORS = {
    asia: new PublicKey("MAS1Dt9qreoRMQ14YQuhg8UTZMMzDdKhmkZMECCzk57"),
    eu: new PublicKey("MEUGGrYPxKk17hCr7wpT6s8dtNokZj5U2L57vjYMS8e"),
    us: new PublicKey("MUS3hc9TCw4cGC12vHNoYcCGzJG1txjgQLZWVoeNHNd"),
    tee: new PublicKey("FnE6VJT5QNZdedZPnCoLsARgBwoE6DeJNjBs2H1gySXA"),
  };

  // Helper: derive vault PDA
  function getVaultPDA(id: anchor.BN): [PublicKey, number] {
    return PublicKey.findProgramAddressSync(
      [Buffer.from("obscura_vault"), id.toArrayLike(Buffer, "le", 8)],
      programId
    );
  }

  // Helper: derive permission PDA
  function getPermissionPDA(
    vault: PublicKey,
    permitted: PublicKey
  ): [PublicKey, number] {
    return PublicKey.findProgramAddressSync(
      [
        Buffer.from("obscura_permission"),
        vault.toBuffer(),
        permitted.toBuffer(),
      ],
      programId
    );
  }

  // -----------------------------------------------------------------------
  // Tests
  // -----------------------------------------------------------------------

  /* Uncomment after `anchor build` generates the IDL:

  it("Creates a vault", async () => {
    const [vaultPDA] = getVaultPDA(vaultId);

    const tx = await program.methods
      .createVault(vaultId)
      .accounts({
        vault: vaultPDA,
        owner: owner.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .rpc();

    console.log("Create vault tx:", tx);

    const vaultAccount = await program.account.vaultState.fetch(vaultPDA);
    expect(vaultAccount.owner.toBase58()).to.equal(
      owner.publicKey.toBase58()
    );
    expect(vaultAccount.vaultId.toNumber()).to.equal(1);
    expect(vaultAccount.balance.toNumber()).to.equal(0);
    expect(vaultAccount.isDelegated).to.be.false;
  });

  it("Deposits SOL into vault", async () => {
    const [vaultPDA] = getVaultPDA(vaultId);
    const depositAmount = new anchor.BN(100_000_000); // 0.1 SOL

    const tx = await program.methods
      .deposit(depositAmount)
      .accounts({
        vault: vaultPDA,
        depositor: owner.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .rpc();

    console.log("Deposit tx:", tx);

    const vaultAccount = await program.account.vaultState.fetch(vaultPDA);
    expect(vaultAccount.balance.toNumber()).to.equal(100_000_000);
  });

  it("Delegates vault to ER validator (US)", async () => {
    const [vaultPDA] = getVaultPDA(vaultId);

    const tx = await program.methods
      .delegateVault(VALIDATORS.us)
      .accounts({
        vault: vaultPDA,
        owner: owner.publicKey,
      })
      .rpc();

    console.log("Delegate vault tx:", tx);

    // After delegation, fetching from L1 may not reflect changes immediately;
    // the account is now on the ER validator.
    console.log("Vault delegated to US validator");
  });

  it("Delegates vault to TEE validator (PER)", async () => {
    // Create a separate vault for the PER test
    const perId = new anchor.BN(2);
    const [perVaultPDA] = getVaultPDA(perId);

    await program.methods
      .createVault(perId)
      .accounts({
        vault: perVaultPDA,
        owner: owner.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .rpc();

    const tx = await program.methods
      .delegateVault(VALIDATORS.tee)
      .accounts({
        vault: perVaultPDA,
        owner: owner.publicKey,
      })
      .rpc();

    console.log("Delegate to TEE (PER) tx:", tx);
    console.log("Vault is now in Private Ephemeral Rollup mode");
  });

  it("Creates a permission for PER access control", async () => {
    const [vaultPDA] = getVaultPDA(vaultId);
    const permittedUser = Keypair.generate().publicKey;
    const [permissionPDA] = getPermissionPDA(vaultPDA, permittedUser);

    const tx = await program.methods
      .createPermission(permittedUser)
      .accounts({
        permission: permissionPDA,
        vault: vaultPDA,
        owner: owner.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .rpc();

    console.log("Create permission tx:", tx);

    const permissionAccount =
      await program.account.permissionState.fetch(permissionPDA);
    expect(permissionAccount.permitted.toBase58()).to.equal(
      permittedUser.toBase58()
    );
  });

  it("Withdraws SOL from vault", async () => {
    const [vaultPDA] = getVaultPDA(vaultId);
    const withdrawAmount = new anchor.BN(50_000_000); // 0.05 SOL

    const tx = await program.methods
      .withdraw(withdrawAmount)
      .accounts({
        vault: vaultPDA,
        owner: owner.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .rpc();

    console.log("Withdraw tx:", tx);

    const vaultAccount = await program.account.vaultState.fetch(vaultPDA);
    expect(vaultAccount.balance.toNumber()).to.equal(50_000_000);
  });

  */

  it("Placeholder — build and deploy first, then uncomment tests", () => {
    console.log("=".repeat(60));
    console.log("SETUP INSTRUCTIONS:");
    console.log("=".repeat(60));
    console.log("1. Install deps:   npm install");
    console.log("2. Build program:  anchor build");
    console.log("3. Get program ID: anchor keys list");
    console.log("4. Update program ID in Anchor.toml and lib.rs");
    console.log("5. Rebuild:        anchor build");
    console.log("6. Deploy:         anchor deploy --provider.cluster devnet");
    console.log("7. Uncomment tests above and run: anchor test");
    console.log("=".repeat(60));
    console.log("");
    console.log("Validator endpoints (devnet):");
    console.log("  Asia:", VALIDATORS.asia.toBase58());
    console.log("  EU:  ", VALIDATORS.eu.toBase58());
    console.log("  US:  ", VALIDATORS.us.toBase58());
    console.log("  TEE: ", VALIDATORS.tee.toBase58());
    console.log("");
    console.log("Delegation Program:", DELEGATION_PROGRAM.toBase58());
    expect(true).to.be.true;
  });
});
