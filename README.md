# rehash-install
Works on: Debian 8

Introduction
-
Rehash is a fork of slash, located @ https://github.com/SoylentNews/rehash : the code that powers SoylentNews.org. This script aids in installing rehash on a fresh debian box, for testing purposes.

Information
-
Be warned : This is extremely experimental and only for disposable development setups.
That being said, it should be faster than following the typical INSTALL procedure as outlined in original slash docs.
This script is meant to be temprorary, until rehash installation is made simple and fast for development deployments.

Notes
-
**You must enter service user information multiple times, correctly!** Prepare to have some time on your hands, this compiles the entire environment. This MIGHT work on other (debian-based) distributions.

Install
-----
    wget https://raw.githubusercontent.com/mecctro/rehash-install/master/install.sh &&
    chmod -x install.sh &&
    sh install.sh
