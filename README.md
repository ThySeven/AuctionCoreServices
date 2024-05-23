# AuctionCoreServices

## Getting Started

To get your environment set up and the services running smoothly, please follow these simple steps:

1. **Start the Auction Core Shared Services**  
   Begin by launching the common services needed for both the delivery and logistic aspects of the project. You can do so by executing the following command in your terminal:  
   `docker compose -f docker-compose-auction-shared-services.yml up -d`

2. **Initialize the Vault**  
   Next, set up the default Vault secrets. Simply run:  
   `docker compose -f docker-compose-vault-setup.yml up && docker compose -f docker-compose-vault-setup.yml down`
  
3. **Launch the Auction Core Services**  
   To launch the Auction Core Services, run:  
   `docker compose -f docker-compose-auction-core-services.yml up -d`

   **Alternatively**
   
   To run all:
   `docker compose -f docker-compose-auction-shared-services.yml up -d && sleep 1 && docker compose -f docker-compose-vault-setup.yml up && sleep 1 && docker compose -f docker-compose-vault-setup.yml down && sleep 1 && docker compose -f docker-compose-auction-core-services.yml up -d`

5. **???**  
   ???.

6. **Profit**  
   With everything set up, it's time to see your project come to life and enjoy the fruits of your labor!


## Architecture:
![image](https://github.com/ThySeven/AuctionCoreServices/assets/9445207/27954d72-4d8c-40cc-87cd-cd5011629d32)
![image](https://github.com/ThySeven/AuctionCoreServices/assets/9445207/c95309e5-9a79-4198-8e18-1e986b1b7998)
![image](https://github.com/ThySeven/AuctionCoreServices/assets/9445207/9cdecce1-d814-4198-aa5e-282737123dce)

