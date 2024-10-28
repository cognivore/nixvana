server {
    server_name unity-dashboard-red.zerohr.io;

    location / {
        proxy_pass http://localhost:8713;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/unity-dashboard-red.zerohr.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/unity-dashboard-red.zerohr.io/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = unity-dashboard-red.zerohr.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name unity-dashboard-red.zerohr.io;
    return 404; # managed by Certbot


}
