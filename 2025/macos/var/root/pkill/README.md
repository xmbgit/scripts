# How to import `pkill` CRON job

### a) 
###### Switch to the root user

### b)
###### Import the pkill dir into root home dir

### c) 
###### Add a new cron job
    `sudo crontab -e`

### d)
###### Insert the following into the crontab file
    `* * * * * /var/root/pkill/pkill.sh >> /var/root/pkill/pkill_cron.log 2>&1`

### e) 
###### Ensure that the script is executable before running 
    `sudo chmod +x /var/root/pkill/pkill.sh`
