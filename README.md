# Migration tools to get La Bicicletta on Shopify

1. Put the required keys and stuff in `.env`
2. Install Docker for Mac
3. `cd` into the project directory
4. In a terminal window, run: `docker-compose up`
5. In another terminal window, run: `docker-compose run app bin/migrate`
6. When you're done, run `docker-compose down`
