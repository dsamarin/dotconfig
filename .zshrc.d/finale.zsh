login() { cd ~/dev/prod; `make login ENVIRONMENT=development MFA=$1`; }
loginprod() { cd ~/dev/prod; `make login ENVIRONMENT=production MFA=$1`; }
