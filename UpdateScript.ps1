systemctl stop nginx
rm -rf /var/www/GuildLUA/*
cp -r /home/name/GuildLUA/* /var/www/GuildLUA/
systemctl start nginx