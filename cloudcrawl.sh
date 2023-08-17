#!/usr/bin/bash

# ask the user what domain they want to crawl, entered domain is stored in the variable #domain
echo "Enter domain to crawl"

read domain

# initiate crawl from screamingfrogseospider without GUI (headless) and define the output folder as the crawl-data directory
screamingfrogseospider --crawl $domain --headless --output-folder ~/crawl-data/ \
--export-tabs "Internal:All,Directives:All" --overwrite --bulk-export "All Inlinks" # data should be exported from these tabs in the .deb


now=$(date +"%Y_%m_%d") #defines date
filename=${domain//./_} # defines filename based on domain name
filename=${filename//-/_} # replace '-' with '_'
filename=${filename////_} # replace '/' with '_'
#filename="$filename"_"$now"

bq mk ${filename}_sf_crawls # creates dataset in bigquery based on the filename

# replace null values with spaces in the csv files
tr '\0' ' ' < ~/crawl-data/internal_all.csv > ~/crawl-data/internal_all_clean.csv
tr '\0' ' ' < ~/crawl-data/directives_all.csv > ~/crawl-data/directives_all_clean.csv
tr '\0' ' ' < ~/crawl-data/all_inlinks.csv > ~/crawl-data/all_inlinks_clean.csv
tr '\0' ' ' < ~/crawl-data/all_inlinks.csv > ~/crawl-data/hreflang_all_clean.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.internal${now} ~/crawl-data/internal_all_clean.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.directives${now} ~/crawl-data/directives_all_clean.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.inlinks_${now} ~/crawl-data/all_inlinks_clean.csv

bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.hreflang.csv${now} ~/crawl-data/hreflang_all_clean.csv

curl -i -H "Content-Type:application/json; charset=UTF-8" --data '{"text":"'"$domain"' crawl complete"}' "https://chat.googleapis.com/{token}"
