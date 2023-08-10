#!/usr/bin/bash

# Ask the user what domain they want to crawl. The entered domain is stored in the variable #domain 
echo "Enter domain to crawl"
read domain

# Path to the .seospiderconfig file
CONFIG_PATH="/home/clients/SEO\ Spider\ Config.seospiderconfig"

# Initiate crawl from screamingfrogseospider without GUI (headless) and define the output folder as the crawl-data directory 
screamingfrogseospider --crawl $domain --headless --config $CONFIG_PATH --output-folder ~/crawl-data/ \
--export-tabs "Internal:All,Directives:All" --overwrite --bulk-export "All Inlinks" 

now=$(date +"%Y_%m_%d") # Defines date 
filename=${domain//./_} # Defines filename based on domain name

bq mk ${filename}_sf_crawls # Creates dataset in bigquery based on the filename 

# Replace null values with spaces in the csv files 
tr '\0' ' ' < ~/crawl-data/internal_all.csv > ~/crawl-data/internal_all_clean.csv
tr '\0' ' ' < ~/crawl-data/directives_all.csv > ~/crawl-data/directives_all_clean.csv
tr '\0' ' ' < ~/crawl-data/all_inlinks.csv > ~/crawl-data/all_inlinks_clean.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.internal${now} ~/crawl-data/internal_all_clean.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.directives${now} ~/crawl-data/directives_all_clean.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.inlinks${now} ~/crawl-data/all_inlinks_clean.csv

curl -i -H "Content-Type:application/json; charset=UTF-8" --data '{"text":"'"$domain"' crawl complete"}' "https://chat.googleapis.com/{token}"

