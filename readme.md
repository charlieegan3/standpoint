# Points Extraction

Tool to analyze discursive texts with the goal of extracting key points raised and the relationships between them.

## Contributing

I cannot accept contributions to the project before May 2016 as it must be all my own work. Please feel free to fork the project. The project is uses the MIT license.

## Setup Instructions

This guide will list steps to compelte the analysis for a single arbitrary discussion. The only software that you need to install on you computer is Docker and Docker compose. Docker hosts lightweight virtual machines called containers that run each of our services.

### Installation
1. [Install Docker](https://docs.docker.com/engine/installation/) and the [Docker Compose interface](https://docs.docker.com/compose/install/). This varies depending on the host operating system.
2. Check that you can run `docker ps` and see output starting: `CONTAINER ID...`
3. Change directory into the project folder `cd {project-folder-path}`
4. Run `docker-compose build`, this will download all the dependencies for each of the project's services. This includes a series of operating system images and the CoreNLP framework and will take some time (allow 20-25 mins on a 20mbps connection, time also depends on the rescources allocated to Docker).

### Setting Up a Corpus
1. First you need to get a corpus in place to run the analysis on. This guide will talk you through using the Abortion corpus we used. Download the corpus to the `analysis_api` folder: `curl -L https://gist.github.com/charlieegan3/5662280729f19a154f5e118eec26315c/archive/e8a879bdb9aab88d5f570f43fff0d91f6ccad34a.zip > analysis_api/abortion.zip`
2. Now unzip the downloaded corpus: `unzip analysis_api/abortion.zip -d analysis_api/abortion && mv analysis_api/abortion/**/* analysis_api/abortion/ && rm -r analysis_api/abortion/5*`
3. (OPTIONAL) Inspect a corpus file: `cat analysis_api/abortion/post_1`. Lines like `#key=value` are parsed into metadata. These are optional.
4. It is now time to start a console in the `analysis_api` service. Todo this run: `docker-compose run analysis_api /bin/bash`.
5. You will now have a new prompt `/app#`. The current directory is `analysis_api`, file changes are synced between this container and the host. Type `ls` and you will see the contents of the `analysis_api` folder.
6. Before extracting points from the corpus we need to clean the posts for invalid characters and parse any metadata. Run `ruby clean.rb abortion` to do this for all of the files in raw abortion corpus we downloaded.

### Extracting Points
1. You are now ready to extract a list of points from the corpus. To do this run `ruby collector.rb abortion`. This will take some around 10-15 mins and is quite an intensive task. Output is written to `abortion_points.txt` in the `analysis_api` directory. This will be a large file (~50mb), The first line is a list of topics and the following lines represent each point in JSON.
2. When you have finished running the points extraction process you  can exit the analysis_api console with `exit`.

### Cleaning/Curating Points
1. To prepare the list of points for use in summarization they must first be reformatted. First you need to move your extracted points file into the `curator` directory. From the project root run: `mv analysis_api/abortion_points.txt curator/abortion_points.txt`
2. From the project root directory run `docker-compose run curator /bin/bash` to get a console ready to run the curation task.
3. To clean the list for summarization run: `go run main.go abortion_points.txt > abortion_points_clean.txt`

### Generating a Summaries
1. First get a clean list of points to use in generating the summary. From the project root run: `mv curator/abortion_points_clean.txt summarizer/abortion_points_clean.txt`.
2. Now run: `docker-compose run summarizer /bin/bash` to get a console prepared for generating summaries.
3. To generate a summary for your clean list of points run: `ruby summarizer.rb abortion_points_clean.txt`
4. This will save a file in the `summarizer` directory called `abortion_formatted.html`. This is the end result and should be viewed in a browser.
