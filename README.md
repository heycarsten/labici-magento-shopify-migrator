# Migration tools to get La Bicicletta on Shopify

You are looking at is the result of my effots to help La Bicicletta (a bike shop in Toronto, Canada) migrate their online store from Magento to Shopify.

## Staging the Magento data

1. Dump the Magento MySQL database (PHPMyAdmin w/ simple default options works) and place the dumped SQL file into `data/megento_db`
2. Copy the Magento media files found in `media/catalog` into `data/magento_media`

## Running the migrator

1. Put the required keys and stuff in `.env`
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
3. `cd` into this project directory
4. In a terminal window, run: `docker-compose up`
5. In another terminal window, run: `docker-compose exec app bin/migrate`
6. When you're done, run `docker-compose down`
