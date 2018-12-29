# Tooling to migrate data from Magento 1.9 to Shopify

What you're looking at is the result of my efforts to help [La Bicicletta](https://labicicletta.com) (a bike shop in Toronto, Canada) migrate their online store from Magento to Shopify.

Thanks to La Bicicletta for releasing this work as open source software! They are a great bunch of humans, giving back to their community by supporting causes like [Toronto Hustle](https://www.toronto-hustle.com/welcome-1). They also happen to run one of the finest bike shops in Toronto and online! Check them out:

<br>
<p align="center">
  <a href="https://labicicletta.com">
    <img height="52px" alt="La Bicicletta" src="https://snappities.s3.amazonaws.com/zcd003bl4xvc1vv9iri4.png">
  </a>
</p>
<br>

## Background :bike:

Magento was not meeting the needs of the business anymore, the decision was made to move to Shopify. There was a lot of data in Magento, ideally it could be moved to Shopify with some form of automation. Over the course of about 40h of time I went from never having looked at a Magento database schema, to what you are looking at.

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
8. Run a command: `docker-compose run --rm app bin/console`
9. When you're done, find the terminal running `docker-compose up` and press `Ctrl+C` to shut it down

### `bin/console`

This loads up the project and provides an interactive console, you can interact with all of the classes and objects in the project this way.

See a list of tables in the Magento database:

```ruby
mag = LaBici::Magento.new
mag.db.tables
```

Search customers in Shopify:

```ruby
shop = LaBici::Shopify.new
shop.search_customers('favecustomer@example.com')
```

You get the idea :slightly_smiling_face:

### `bin/run`

This is used for doing the data migrations, there are four different tasks:

- `bin/run migrate-simple-products` will migrate all active "simple" products from Magento to Shopify
- `bin/run migrate-configurable-products` will migrate all active "configurable" products from Magento to Shopify. Have a look at the code, odds are your store will have different fields and stuff you want to export, it should give you a rough idea of how to do this
- `bin/run migrate-customers` will migrate all active customers from Magento into Shopify. Shopify is pretty strict with emails and stuff like that, if your Magento store is big, expect a number of customers to be rejected (fraud usually)
- `bin/run customer-report` will output customer data, this was just me toying around, it may or may not be useful for you

### `bin/activator`

This is used for inviting customers to the Shopify store, you don't have to use this, it's not part of the data migration. You can find the inner workings in `lib/labici/customer_activator.rb` and the available tasks in `bin/activator`.

The workflow for using this is:

- Export as CSV the users you wish to activate from the Shopify Admin interface and place this file in `data/customers.csv`
- Run `bin/activator import-customers-csv`, this will load all of the customers you wish to generate activation URLs for
- Run `bin/activator sync-activation-urls`, this will atomically generate activation URLs for each customer in `data/customers.csv`
- Run `bin/activator export-customers-csv`, this will export a new CSV file the same as `bin/customers.csv` but with the addition of an Activation URL, you can then use this to send out a bulk email inviting inactive users to activate in Shopify. This is placed in `data/customers-with-activation-urls.csv`

## Questions :thinking: / Ideas :scream:

Open a ticket and I'll try to respond as quickly as I can.
