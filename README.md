# le-cert-expiry

## The CA and cert chains
                                         root1(expired)
                                           /  
                                         /  
    root2selfsigned        root2(cross-signed)   
             \             /  
               \          /  
               Intermediate  
                   |  
                   |  
                 server   

## Steps to generate the certs
  We can use `gencerts.sh` to generate the required certs. But this would need us to wait for a day for root1 to expire. We can directly consume the certs in the repo, though.  
## Steps to run the client, server
  ```
  npm i
  ./node_modules/.bin/electron server.js
  ```
