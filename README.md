# Root certificate expires that has cross signed another root (valid, non expired)
For compatibility and acceptance reasons, new certificate autorities like lets encrypt gets it's root cross signed[1] by a widely accepted root.
While the cross signed certificate is consumed by the audience, the new CA will try to ship it's root certificates to all the clients.
Note: The server exchanges it's certificate along with the cross signed root's certificate in order for the client to build the chain leading to the root in client's trust store.

When the new CA's self signed root certificates reach the clients, the clients should build the certificate chain leading to the self signed root. So that all the certificates issued by the intermediate certificate authority, are accepted as valid certs.
Note: Only the self signed root reaches the client trust store, not the cross signed one.  

Unfortunately, when the root that cross signed expires, it also leads to the leaf certs issues by the cross signed roots are treated invalid.
Real world examples for this scenario can be lets encrypt[2]

To mitigate this scenario, clients and servers needed to make some changes. Here is the blog post[3] from openssl that addresses the issue.
We are interested in the client's action item: Using the `X509_V_FLAG_TRUSTED_FIRST` flag for verification. This makes client prefer the trust store certificates over the untrusted certificates in the chain provided by the peer.
Here is the reference PR[4] that does the same.
This test tries to verify that client should build a certificate chain that contains a valid root.

[1] https://letsencrypt.org/docs/glossary/#def-cross-signing
[2] https://letsencrypt.org/docs/dst-root-ca-x3-expiration-september-2021/
[3] https://www.openssl.org/blog/blog/2021/09/13/LetsEncryptRootCertExpire/
[4] https://github.com/electron/electron/pull/31213  
## The CA and cert chains
                                         root1(expired)
                                           /  
                                         /  
    root2selfsigned        root2(cross-signed)   
             \              /  
               \           /  
               Intermediate  
                     |  
                     |  
                   server   

## Steps to generate the certs
  We can use `gencerts.sh` to generate the required certs. But this would need us to wait for a day for root1 to expire. We can directly consume the certs in the repo, though.  
### The included certificate details including validity
#### Root1 (Self signed, expired)
``` >> openssl x509 -in root1.cert.pem -noout -subject -dates -issuer  
subject= /CN=root1.starship.com
notBefore=Mar 12 19:25:19 2022 GMT
notAfter=Mar 13 19:25:19 2022 GMT
issuer= /CN=root1.starship.com
```  
#### Root2 (Cross signed by Root1, valid)
``` >> openssl x509 -in root2.cert.pem -noout -subject -dates -issuer  
subject= /CN=root2.starship.com
notBefore=Mar 12 19:25:20 2022 GMT
notAfter=Mar  7 19:25:20 2042 GMT
issuer= /CN=root1.starship.com
```  
#### Root2SelfSigned (Self signed, valid)
``` >> openssl x509 -in root2selfsigned.cert.pem -noout -subject -dates -issuer  
subject= /CN=root2.starship.com
notBefore=Mar 30 16:25:40 2022 GMT
notAfter=Jan 24 16:25:40 2023 GMT
issuer= /CN=root2.starship.com 
```  
#### Intermediate (Signed by Root2, valid)
``` >> openssl x509 -in intermediate.cert.pem -noout -subject -dates -issuer  
subject= /CN=intermediate.starship.com
notBefore=Mar 12 19:25:22 2022 GMT
notAfter=Mar  9 19:25:22 2032 GMT
issuer= /CN=root2.starship.com
```  
#### Leaf/Server (Sigen/issued by Intermediate, valid)
``` >> openssl x509 -in server.cert.pem -noout -subject -dates -issuer  
subject= /CN=localhost
notBefore=Mar 12 19:25:23 2022 GMT
notAfter=Mar 22 19:25:23 2023 GMT
issuer= /CN=intermediate.starship.com
```  
## Steps to run the client, server
  ```
  npm i
  npm test 
  ```
## Steps to simulate the cert expiry error  
The issue can be reproduced with electron v11.  
```
npm i electron@11
npm i
npm test
```

