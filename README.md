

# Commands to Host Chainlink Node

Elevate to Root 
sudo su -

Install Docker on Ubuntu

curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $USER
exit

Make a ChainLink Folder
mkdir ~/.chainlink

Create an Account (Ethereum Node) on Alchemy
https://www.alchemy.com/
https://dashboard.alchemyapi.io/

Install Light Weight Postgres Client
sudo apt install -y postgresql-client

Test Database Connection to Google Cloud SQL
pg_isready -d chainlinkdb2 -h 35.223.13.41 -p 5432 -U postgres

Create .env config file
ROOT=/chainlink
LOG_LEVEL=debug
ETH_CHAIN_ID=1
CHAINLINK_TLS_PORT=0
SECURE_COOKIES=false
ALLOW_ORIGINS=*
ETH_URL=
DATABASE_URL=


Download and Run the Chain Link Node via Docker
docker run -p 6688:6688 -v ~/.chainlink:/chainlink -it --env-file=.env smartcontract/chainlink:1.7.0-root local n

Install NGINX
apt-get install nginx

Modify NGINX Server Block

 location ~ / {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://localhost:6688;
 }

service nginx reload
service nginx restart

Keystore Credential Requirements
- Don’t use numbers
- 4 uppercase letters
- Greater than 16 chars

# Chainlink Node Operator creds

Hosted on  :
`
http://34.125.213.96/
`

# Request compute steps

1. Deploy the RequestComputeGPU.sol and RequestOutputLog.sol and fill them with Goerli LINK tokens 5-10.

2. Look for `requestCompute` function and enter the following creds and URL for compute.

oracle_address: `0xd0905cB54D3934F4c746AE1c15de4662310993C0`

jobID: `4dfdc7e76f114404a71489de493d88f4`

example fileURL: `https://raw.githubusercontent.com/madhukar123456/kaggle-kernel/main/python-code/mistraltest.ipynb`