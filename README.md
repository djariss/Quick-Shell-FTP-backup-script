<h1>Quick-Shell-backup-script</h1>

Small shell script for providing backup solution for your website and databases with support for incremential backups and FTP backup.

<h3>INSTALATION</h3>

In order to use the script, upload it to your website, for example inside /root/quick-shell-backup-script.sh

Then open up the script file using your favourite editor, for example vi /root/quick-shell-backup-script.sh

Replace the values for MySQL root password, replace the FTP account access details with your own.

<h3>SETUP CRON JOB</h3>

If you don't have any control panel for your webserver, you can enter the cron job command by editing /etc/crontab. So, just type in vi /etc/crontab and add this line inside and save changes.

0 3 * * * sh /root/quick-shell-backup-script.sh

You can also specify some other time per your own needs, the example from above will execure the backup on 3h in the morning. 

If you need any assistance or support on this one, please get in touch with me at djariss@gmail.com
