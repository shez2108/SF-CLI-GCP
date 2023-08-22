#!/usr/bin/bash

# ask the user what domain they want to crawl, entered domain is stored in the variable #domain
echo "Enter domain to crawl"

read domain

configpath="/home/clients/Config.seospiderconfig"

# initiate crawl from screamingfrogseospider without GUI (headless) and define the output folder as the crawl-data directory
screamingfrogseospider --crawl "$domain" --headless --config "$configpath" --output-folder ~/crawl-data/ \
--export-tabs "Internal:All,Directives:All,Hreflang:All,Pagination:All,Structured Data:All,Sitemaps:All,JavaScript:All,Links:All" --overwrite --bulk-export "All Inlinks,Near Duplicates,Exact Duplicates" 
# data should be exported from these tabs in the .deb


now=$(date +"%Y_%m_%d") #defines date
filename=${domain//./_} # defines filename based on domain name
filename=${filename//-/_} # replace '-' with '_'
filename=${filename////_} # replace '/' with '_'
#filename="$filename"_"$now"

if ! bq ls ${filename}_sf_crawls &>/dev/null; then
  bq mk ${filename}_sf_crawls # creates dataset in bigquery based on the filename
fi

# Check if the file exists
#if [ ! -f ~/crawl-data/internal_all.csv ]; then
    #echo "Error: internal_all.csv does not exist."
    #exit 1
#fi
# replace null values with spaces in the csv files
#tr '\0' ' ' < ~/crawl-data/internal_all.csv > ~/crawl-data/internal_all_clean.csv

#bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
#${filename}_sf_crawls.internal${now} ~/crawl-data/internal_all_clean.csv

#if [ ! -f ~/crawl-data/directives_all.csv ]; then
    #echo "Error: directives_all.csv does not exist."
    #exit 1
#fi
#tr '\0' ' ' < ~/crawl-data/directives_all.csv > ~/crawl-data/directives_all_clean.csv

#bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
#${filename}_sf_crawls.directives${now} ~/crawl-data/directives_all_clean.csv

#if [ ! -f ~/crawl-data/sitemaps_all.csv ]; then
    #echo "Error: sitemaps_all.csv does not exist."
    #exit 1
#fi
#tr '\0' ' ' < ~/crawl-data/sitemaps_all.csv > ~/crawl-data/sitemaps_all_clean.csv
#bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
#${filename}_sf_crawls.sitemaps${now} ~/crawl-data/sitemaps_all_clean.csv

#if [ ! -f ~/crawl-data/all_inlinks.csv ]; then
    #echo "Error: all_inlinks.csv does not exist."
    #exit 1
#fi
#tr '\0' ' ' < ~/crawl-data/all_inlinks.csv > ~/crawl-data/all_inlinks_clean.csv
#bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
#${filename}_sf_crawls.inlinks_${now} ~/crawl-data/all_inlinks_clean.csv

#if [ ! -f ~/crawl-data/pagination_all.csv ]; then
    #echo "Error: pagination_all.csv does not exist."
    #exit 1
#fi
#tr '\0' ' ' < ~/crawl-data/pagination_all.csv > ~/crawl-data/pagination_all_clean.csv
#bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
#${filename}_sf_crawls.pagination${now} ~/crawl-data/pagination_all_clean.csv

#if [ ! -f ~/crawl-data/hreflang_all.csv ]; then
    #echo "Error: hreflang_all.csv does not exist."
    #exit 1
#fi
#tr '\0' ' ' < ~/crawl-data/hreflang_all.csv > ~/crawl-data/hreflang_all_clean.csv 
#bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
#${filename}_sf_crawls.hreflang${now} ~/crawl-data/hreflang_all_clean.csv

if [ ! -f ~/crawl-data/structured_data_all.csv ]; then
    echo "Error: structured_data_all.csv does not exist."
    exit 1
fi
tr '\0' ' ' < ~/crawl-data/structured_data_all.csv > ~/crawl-data/structured_data_all_clean.csv
bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.structured_data${now} ~/crawl-data/structured_data_all_clean.csv

if [ ! -f ~/crawl-data/javascript_all.csv ]; then
    echo "Error: javascript_all.csv does not exist."
    exit 1
fi
tr '\0' ' ' < ~/crawl-data/javascript_all.csv > ~/crawl-data/javascript_all_clean.csv
bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.javascript_all${now} ~/crawl-data/javascript_all_clean.csv

if [ ! -f ~/crawl-data/links_all.csv ]; then
    echo "Error: links_all.csv does not exist."
    exit 1
fi
tr '\0' ' ' < ~/crawl-data/links_all.csv > ~/crawl-data/links_all_clean.csv
bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.links_all${now} ~/crawl-data/links_all_clean.csv

if [ ! -f ~/crawl-data/exact_duplicates_report.csv ]; then
    echo "Error: exact_duplicates_report.csv does not exist."
    exit 1
fi
tr '\0' ' ' < ~/crawl-data/exact_duplicates_report.csv > ~/crawl-data/exact_duplicates_report_clean.csv
bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.exact_duplicates_report${now} ~/crawl-data/exact_duplicates_report_clean.csv

if [ ! -f ~/crawl-data/exact_duplicates_report.csv ]; then
    echo "Error: exact_duplicates_report.csv does not exist."
    exit 1
fi
tr '\0' ' ' < ~/crawl-data/exact_duplicates_report.csv > ~/crawl-data/exact_duplicates_report_clean.csv
bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.exact_duplicates_report${now} ~/crawl-data/exact_duplicates_report_clean.csv

if [ ! -f ~/crawl-data/near_duplicates_report.csv ]; then
    echo "Error: near_duplicates_report.csv does not exist."
    exit 1
fi
tr '\0' ' ' < ~/crawl-data/near_duplicates_report.csv > ~/crawl-data/near_duplicates_report_clean.csv
bq load --autodetect --source_format=CSV --allow_quoted_newlines --allow_jagged_rows --ignore_unknown_values \
${filename}_sf_crawls.near_duplicates_report${now} ~/crawl-data/near_duplicates_report_clean.csv


curl -i -H "Content-Type:application/json; charset=UTF-8" --data '{"text":"'"$domain"' crawl complete"}' "https://chat.googleapis.com/{token}"

# Create a GCS bucket
if ! gsutil ls gs://${filename}/ &>/dev/null; then
  gsutil mb gs://${filename}/
fi

# Upload the cleaned CSV files to the GCS bucket
gsutil cp ~/crawl-data/*_clean.csv gs://${filename}/sf-crawl-data
