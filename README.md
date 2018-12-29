# Tooling to migrate data from Magento 1.9 to Shopify

You are looking at is the result of my efforts to help [La Bicicletta](https://labicicletta.com) (a bike shop in Toronto, Canada) migrate their online store from Magento to Shopify. It is very specific to

Thanks to La Bicicletta for releasing this work as open source software! They are a great bunch of humans, giving back to their community by supporting causes like [Toronto Hustle](https://www.toronto-hustle.com/welcome-1). They also happen to run one of the finest bike shops in Toronto and online! Check them out:

<br>
<p align="center">
  <a href="https://labicicletta.com">
    <img height="52px" alt="La Bicicletta" src="https://snappities.s3.amazonaws.com/zcd003bl4xvc1vv9iri4.png">
  </a>
</p>
<br>

## Background :bike:

Magento was not meeting the needs of the business anymore, the decision was made to move to Shopify. There was a lot of data in Magento, ideally it could be moved to Shopify with some form of automation. Over the course of about 40h of time I went from never having looked at a Magento database schema, to having successfully migrated all products, categories, and customers to Shopify.

This codebase is heavily tied to the requirements of this specific migration, but I think there is a lot to learn in here and apply to your own migration.

## Layout / Overview :raised_hands:

The overall workflow here is:

- Get the data out of Magento and place it in the `data` directory
- Register with Shopify and generate an API key with admin access
- Run the migrations to export simple products and configurable products to Shopify
- Run the migration to export customers to Shopify

For us this was the right mix of automation and manual effort, that might be different for you.

## Staging the Magento data :hammer:

1. Dump the Magento MySQL database (PHPMyAdmin w/ simple default options works) and place the dumped SQL file into `data/megento_db` Docker will pick it up when you build. _NOTE: the `.sql` file can have any name_
2. Copy the Magento media files found in `media/catalog` (on your web server hosting Magento) into `data/magento_media`

The directory structure should look something like this:

![](https://snappities.s3.amazonaws.com/7t3b20qrk128ubgds6ij.png)

## Running the migrator :sparkles:

1. Put the required keys and stuff in `.env`
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
3. `cd` into this project directory
4. Open a terminal window
5. (First time) Run: `docker-compose build` to build the containers
6. Run: `docker-compose up` to start the database
7. Open another terminal window or tab
8. Run a command: `docker-compose exec app bin/console` (look in the `bin` directory for more)
9. When you're done, find the terminal running `docker-compose up` and press `Ctrl+C` to shut it down

## Questions :thinking: / Ideas :scream:

Open a ticket and I'll try to respond as quickly as I can.
