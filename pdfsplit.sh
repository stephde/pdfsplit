#!/usr/bin/env bash

# this script splits the given pdf document in multiple documents with the desired page count
# prerequesites: pdfinfo, pdfseparate and pdfunite have to be preinstalled
#   on mac run brew install poppler to install the dependencies

# example usage: ./split_pdf.sh path/to/doc.pdf 4

FILE=$1
if [[ ! -f ${FILE} ]] ; then
    echo "Argmument 1 has to be a path to an existing pdf file!"
    exit
fi
if [[ "${FILE}" =~ \ |\' ]]; then
   echo "Filepath must not contain whitespaces!"
   exit
fi

DESIRED_NUM_PAGES=$2
regex='^[0-9]+$'
if ! [[ ${DESIRED_NUM_PAGES} =~ ${regex} ]] ; then
    echo "Argmument 2 should be the desired resulting page number! Continuing with default 3"
    DESIRED_NUM_PAGES=3
fi

FILE_NAME=$(basename "${FILE}")
NUM_PAGES=$(pdfinfo ${FILE} | grep Pages | awk '{print $2}')
TEMP_DIR="pdf_temp"


# create temp dir if not existing yet
[ -d ${TEMP_DIR} ] || mkdir ${TEMP_DIR}

# separate document in 1 page documents
PDF_SEP_PATTERN="./${TEMP_DIR}/temp_${FILE_NAME}%d.pdf"
echo ${PDF_SEP_PATTERN}
pdfseparate ${FILE} ${PDF_SEP_PATTERN}

# return if DESIRED_NUM_PAGES < 2
[ ${DESIRED_NUM_PAGES} -lt 2 ] && exit 0

# reunite documents to desired page size
i=1
while ((i < ${NUM_PAGES})); do
    echo $i

    j=0
    unite_args=""
    while ((j < ${DESIRED_NUM_PAGES})); do
        # break if i+j > num_pages
        [ $((${i}+${j})) -gt ${NUM_PAGES} ] && break

        cur_file_index=$((${i}+${j}))
        unite_args="${unite_args} ./${TEMP_DIR}/temp_${FILE_NAME}${cur_file_index}.pdf"
        j=$((${j}+1))
    done

    pdfunite ${unite_args} "./${TEMP_DIR}/${FILE_NAME}${i}.pdf"
    i=$((${i}+${DESIRED_NUM_PAGES}))
done

# remove temp documents
find "./${TEMP_DIR}" -type f -name temp\* -exec rm {} \;
