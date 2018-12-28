# Migration tools to get La Bicicletta on Shopify

## Getting the data

1. For the Magento database PHPMyAdmin and export it with simple default options and place the dumped file into `data/megento_db`
2. For the Magento media files found in `media/catalog` download the contents into `data/magento_media`

## Using the migrator

1. Put the required keys and stuff in `.env`
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
3. `cd` into this project directory
4. In a terminal window, run: `docker-compose up`
5. In another terminal window, run: `docker-compose exec app bin/migrate`
6. When you're done, run `docker-compose down`
