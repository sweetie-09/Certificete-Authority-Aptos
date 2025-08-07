module sweety_addr::CertificateIssuer {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::string::{Self, String};
    use std::vector;

    struct Certificate has store, key {
        issuer: address,           
        recipient: address,        
        certificate_hash: String,  
        issue_date: u64,         
        is_valid: bool,           
    }

    
    struct CertificateRegistry has store, key {
        certificates: vector<String>, 
        total_issued: u64,            
    }

    public fun initialize_authority(authority: &signer) {
        let registry = CertificateRegistry {
            certificates: vector::empty<String>(),
            total_issued: 0,
        };
        move_to(authority, registry);
    }

    
    public fun issue_certificate(
        authority: &signer,
        recipient: address,
        certificate_hash: String
    ) acquires CertificateRegistry {
        let authority_addr = signer::address_of(authority);
        let current_time = timestamp::now_seconds();
        
        let certificate = Certificate {
            issuer: authority_addr,
            recipient,
            certificate_hash: certificate_hash,
            issue_date: current_time,
            is_valid: true,
        };
        
       
        move_to(authority, certificate);
        
        
        let registry = borrow_global_mut<CertificateRegistry>(authority_addr);
        vector::push_back(&mut registry.certificates, certificate_hash);
        registry.total_issued = registry.total_issued + 1;
    }

}
