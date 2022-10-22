# Native PostgreSQL for Google Cloud

A module to install PostgreSQL in a vm instance on Debian, without containers in the middle. 


## Setting up

The SA Account requires special permissions to access to a google storage bucket
see:
https://github.com/nuxion/k3s-platform/blob/6217a8454eafa62191d456743d646de8ef700836/scripts/google/postgres.sh


## Checking subnet

```
gcloud alpha compute networks list-ip-addresses prod
```

or 

```
gcloud alpha compute networks list-ip-addresses prod | grep ${REGION}
```
