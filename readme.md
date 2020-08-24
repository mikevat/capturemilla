# Readme

This repo contains the etl process to transform the Ethereum blockchain data - transactions, traces and smart contracts for the time period of 30 of July 2015 and up to and including 22 of November 2019 (from the genesis block up to block 8983277). Subsequently, follows the replication of the study of Kiffer, L., et al. (2018) for the first 5 million blocks (up to 30 January 2018), extended to the blocks of the above time period. This part involves a descriptive analysis of the Ethereum dataset that gives a wide view of the data at hand and especially the structure and usage patterns of smart contracts. Finally, a smart contract categorization is performed and a clustering algorithm to group contracts with similar codes.

The BigQuery platform and the ethereum sample dataset is used. The main files are in the python_scripts folder:

- 1.bq_ether_etl.ipynb : runs all BigQuery SQL scripts that transform the ethereum dataset for this analysis needs.
- 2.G5 identical bytecode - opcode.ipynb : counts identical contracts based on their bytecode or opcode
- 3.G6 Contract n-gram similarity.ipynb & 4.G6 Contract n-gram similarity.py : clusters smart contracts, based on their opcode similarity