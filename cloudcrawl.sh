#!/usr/bin/bash

# ask the user what domain they want to crawl 
echo "Enter domain to crawl"

read domain

# initiate crawl from screamingfrogseospider without GUI (headless) and define the output folder as the crawl-data directory 
screamingfrogseospider --crawl $domain --headless --output-folder ~/crawl-data/ \
--export-tabs "Internal:All,Directives:All" --overwrite --bulk-export "All Inlinks" # data should be exported from these tabs in the .deb

# defines filename based on date and domain 
now=$(date +"%Y_%m_%d")
filename=${domain//./_}
filename="$filename"_"$now"
bq mk ${filename} # creates directory in bigquery based on the filename 

# replace null values with spaces in the csv files 
tr '\0' ' ' < ~/crawl-data/${filename}_internal_all_${now}.csv > ~/crawl-data/${filename}_internal_all_clean_${now}.csv
tr '\0' ' ' < ~/crawl-data/${filename}_directives_all_${now}.csv > ~/crawl-data/${filename}_directives_all_clean_${now}.csv
tr '\0' ' ' < ~/crawl-data/${filename}_all_inlinks_${now}.csv > ~/crawl-data/${filename}_all_inlinks_clean_${now}.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}.screaming_frog_crawls_internal_all_${now} ~/crawl-data/${filename}_internal_all_${now}.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}.screaming_frog_crawls_directives_all_${now} ~/crawl-data/${filename}_directives_all_${now}.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}.screaming_frog_crawls_all_inlinks_${now} ~/crawl-data/${filename}_all_inlinks_${now}.csv


curl -i -H "Content-Type:application/json; charset=UTF-8" --data '{"text":"'"$domain"' crawl complete"}' "https://chat.googleapis.com/{token}"
