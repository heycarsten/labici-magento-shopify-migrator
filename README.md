# Migration tools to get La Bicicletta on Shopify

## Getting the data

1. For the database PHPMyAdmin and export it with simple default options and place the dumped file into data/megento_db
2. For the media files use FTP ftp://labicicletta.com//htdocs/media/catalog and download the contents into data/magento_media

## Using the migrator

1. Put the required keys and stuff in `.env`
2. Install Docker for Mac
3. `cd` into the project directory
4. In a terminal window, run: `docker-compose up`
5. In another terminal window, run: `docker-compose run app bin/migrate`
6. When you're done, run `docker-compose down`
