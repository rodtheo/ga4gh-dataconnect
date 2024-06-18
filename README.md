# GA4GH Data Connect

This repository is based on contents for [Session 2A of the 2022 FASP Hackathon](https://www.youtube.com/watch?v=6xRGv83ToMs).
Repo: https://github.com/DNAstack/fasp-hackathon-2022.git

## Prerequisites

Install crate [just](https://crates.io/crates/just).

Make sure you have `Docker` installed and running.

Check all options available with `just -l` inside the main directory.


## First things

1. Clone this repo
2. cd `data-connect-trino`
3. git checkout `2dc1606517f7b725d1603722ac9f9d642c80ce7b`
4. cd ..
5. just setup-infra
6. just setup-config
7. go to http://localhost:8089/tables
