<p align="center">
  <img src="http://i.imgur.com/GfkiN7o.jpg" alt="standpoint logo"/>
</p>

Standpoint is a tool for analyzing large online discussions. The approach implemented in the Standpoint application was developed as part of an undergraduate project at the University of Aberdeen. The work was written up as a [conference paper](https://scholar.google.co.uk/citations?view_op=view_citation&hl=en&user=pqb-ZNAAAAAJ&citation_for_view=pqb-ZNAAAAAJ:u5HHmVD_uO8C) and as an [honors thesis](http://charlieegan3.com/timeline/2016-07-20-summarising-the-points/thesis.pdf).

This repository contains the history for that academic project and is now the repo for the 'Standpoint Application'; [standpoint.io](http://standpoint.io) is a hosted instance of the application. This allows visitors to queue analysis jobs for online discussions on Hacker News and Reddit. It is also possible to manually submit a collection of comments (from any site) for analysis.

## Application Services

The application is implemented as a series of services. These run in containers described in `docker-compose.yml`.

* *caddy*: production web server for the standpoint.io site. Configured to proxy requests to the app and serve static assets.
* *point_extractor*: implantation of the points extraction approach. Makes use of dependency graphs and matches patterns within them to find points. The process is detailed in the paper and thesis linked above.
* *corenlp_server*: a container running an copy of [corenlp.run](http://www.corenlp.run). This is provides the dependency parses to the `point_extractor`.
* *standpoint_server*: the Rails app that serves the analysis interface to the point_extractor at standpoint.io.
* *standpoint_worker*: another instance of the rails app, running a worker for analysis jobs rather than the Rails server.
* *standpoint_server_postgres*: this container hosts the database used to store the results of the points extraction analysis. This is used by the worker and the server only.

## Running Standpoint Services

*You must have Docker and Docker Compose installed on the host or developer machine* (inspecting  `playbook.yml` in the project root will give a feel for the application's production prerequisites).

From the project root run `docker-compose pull && docker-compose build`. This will pull and build all the service images.

You will also want to set some environment variables, to use the development defaults run `source dev_env.sh`.

The application is now ready to start. To start up the services as they run on standpoint.io run `docker-compose up -d`. The application will now be available on port 80 of the docker host.

To stop the application run `docker-compose stop`.

To develop on a single service run `docker-compose run -p {external_port}:{internal_port} {service_name} /bin/bash`. From here you can run commands to start the services in development mode.

* Rails server: `RAILS_ENV=development rails s -b 0.0.0.0 -p 3000`
* Rails worker: `RAILS_ENV=development rake jobs:work`
* Points Extractor: `cargo run`

Those commands should be enough to develop on any of the services. Sometimes you'll need to run others in the service environment, e.g. `rake db:migrate`.

## Using the point_extractor from terminal

If you are only interested in extracting points from a list of comments follow these steps:

1. `docker-compose pull && docker-compose build` (technically  you only need to build `core_nlp` and `point_extractor`)
2. Create a text file, one comment per line.
3. Find out your docker host
4. Run `ruby point_extractor_cli.rb {docker_host} {comment_file}`

E.g. `ruby point_extractor_cli.rb http://local.docker:3456 comments.txt`.

Note: the point_extractor runs on 3456 by default.
