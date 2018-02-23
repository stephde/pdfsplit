# pdfsplit
A bash script to split a pdf document into multiple documents with a specific number of pages

this script splits the given pdf document in multiple documents with the desired page count
prerequesites: pdfinfo, pdfseparate and pdfunite have to be preinstalled
-  on mac run brew install poppler to install the dependencies

## Usage
example usage: ./split_pdf.sh path/to/doc.pdf 4
