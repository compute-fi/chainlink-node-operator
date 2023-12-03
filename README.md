

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
pg_isready -d chainlink_6228 -h dpg-cl7kr6f6e7vc739tp9ug-a.oregon-postgres.render.com -p 5432 -U postgres

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

cd /etc/nginx/sites-enabled
vim default

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

# Request compute steps (Quickstart)

`https://goerli.etherscan.io/address/0xfF9aa21FC6aA2fEae61cC776f3F2B23f0Ad5dE4e`

1. Deploy the computeCaller.sol and RequestOutputLog.sol and fill them with Goerli LINK tokens 5-10.

2. Look for `callAPI` function and enter the following creds and URL for compute.

oracle_address: `0x33238F4C8C5C71E1A7a2802e290079665f532FbA`

jobID compute call: `aa491301949d4a4e93d460bdf12c372f`


simple example fileURL: `https://raw.githubusercontent.com/madhukar123456/Mastering-Coding/main/Python/hello_world.py`

AI model example fileURL: `https://raw.githubusercontent.com/madhukar123456/kaggle-kernel/main/python-code/mistraltest.ipynb`

3. Status call `callStatus`

oracle_address: `0x33238F4C8C5C71E1A7a2802e290079665f532FbA`

status call jobID: `6c071cdf64374795a5ea4e238505da46`

computeID: from 2. 

4. Log call `callLog`

oracle_address: `0x33238F4C8C5C71E1A7a2802e290079665f532FbA`

log call jobID: `e74117d2ec984537a3a3db4dba6acf86`
