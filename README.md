# Migration tooling to move from Magento 1.9 to Shopify

You are looking at is the result of my efforts to help [La Bicicletta](https://labicicletta.com) (a bike shop in Toronto, Canada) migrate their online store from Magento to Shopify. It is very specific to

Thanks to La Bicicletta for releasing this work as open source software! They are a great bunch of humans, [supporting their community](https://www.toronto-hustle.com/welcome-1) and beyond. They also happen to run one of the finest bike shops in Toronto and online. Check them out:

<p align="center">
  <a href="https://labicicletta.com">
    <img height="50%" alt="La Bicicletta" src="https://snappities.s3.amazonaws.com/zcd003bl4xvc1vv9iri4.png">
  </a>
</p>

## Staging the Magento data

1. Dump the Magento MySQL database (PHPMyAdmin w/ simple default options works) and place the dumped SQL file into `data/megento_db`
2. Copy the Magento media files found in `media/catalog` into `data/magento_media`

## Running the migrator

1. Put the required keys and stuff in `.env`
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
3. `cd` into this project directory
4. In a terminal window, run: `docker-compose up`
5. In another terminal window, run: `docker-compose run --rm app bin/migrate`
6. When you're done, run `docker-compose down`
