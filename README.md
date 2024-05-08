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
   To get the services for Team 1 and Team 2 up and running, use the command below, replacing `{id}` with `1` or `2` based on the team you're setting up for:  
   `docker compose -f docker-compose-auction-core-services.yml up -d`
  
   Alternatively:
   `docker compose -f docker-compose-team1.yml up -d && docker compose -f docker-compose-team2.yml up -d`

4. **???**  
   ???.

5. **Profit**  
   With everything set up, it's time to see your project come to life and enjoy the fruits of your labor!
