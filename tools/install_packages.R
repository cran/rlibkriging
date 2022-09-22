#!/usr/bin/env Rscript

packages = commandArgs(trailingOnly=TRUE)

for (lib in packages) {

    install.packages(lib, repos='https://cloud.r-project.org');

    if ( ! library(lib, character.only=TRUE, logical.return=TRUE) ) {
        cat(paste("\n#########################\nCannot install", lib, "\n#########################\n\n"))
        quit(status=1, save='no')
    }
}