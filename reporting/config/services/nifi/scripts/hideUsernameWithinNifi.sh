#!/bin/bash

CSS_PATH="/opt/nifi/nifi-current/work/jetty/nifi-web-ui-$1.war/webapp/css"

while [ ! -d $CSS_PATH ] ;
do
    sleep 2
done

cp $CSS_PATH/nf-canvas-all.css /nf-canvas-all.css.backup
echo "#current-user-container{display:none}" >> $CSS_PATH/nf-canvas-all.css
echo "#login-link-container{display:none}" >> $CSS_PATH/nf-canvas-all.css

echo "Username and sign-in menu have been hidden"
