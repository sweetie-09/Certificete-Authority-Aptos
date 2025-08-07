module sweety_addr::CertificateIssuer {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::string::{Self, String};
    use std::vector;

    /// Struct representing a digital certificate
    struct Certificate has store, key {
        issuer: address,           // Address of the certificate issuer
        recipient: address,        // Address of the certificate recipient
        certificate_hash: String,  // Hash of the certificate content
        issue_date: u64,          // Timestamp when certificate was issued
        is_valid: bool,           // Certificate validity status
    }

    /// Struct to store all certificates issued by an authority
    struct CertificateRegistry has store, key {
        certificates: vector<String>,  // List of certificate hashes
        total_issued: u64,            // Total certificates issued
    }

    /// Function to initialize certificate authority
    public fun initialize_authority(authority: &signer) {
        let registry = CertificateRegistry {
            certificates: vector::empty<String>(),
            total_issued: 0,
        };
        move_to(authority, registry);
    }

    /// Function to issue a new certificate
    public fun issue_certificate(
        authority: &signer,
        recipient: address,
        certificate_hash: String
    ) acquires CertificateRegistry {
        let authority_addr = signer::address_of(authority);
        let current_time = timestamp::now_seconds();
        
        // Create new certificate
        let certificate = Certificate {
            issuer: authority_addr,
            recipient,
            certificate_hash: certificate_hash,
            issue_date: current_time,
            is_valid: true,
        };
        
        // Store certificate at recipient's address
        move_to(authority, certificate);
        
        // Update registry
        let registry = borrow_global_mut<CertificateRegistry>(authority_addr);
        vector::push_back(&mut registry.certificates, certificate_hash);
        registry.total_issued = registry.total_issued + 1;
    }
}