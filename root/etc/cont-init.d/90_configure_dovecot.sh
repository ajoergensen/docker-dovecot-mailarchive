#!/usr/bin/with-contenv bash
set -x

: ${PUID:="911"}
: ${PGID:="911"}
: ${MBOXFORMAT:="maildir"}

if [ -n $MAIL_PASSWORD ]
 then
	echo $MAIL_PASSWORD | grep -q CRYPT 
	if [[ $? -ne 0 ]]
	 then
		TMP_PASSWORD=`echo "$MAIL_PASSWORD" | mkpasswd -s -m sha-512`
		MAIL_PASSWORD="{SHA512-CRYPT}$TMP_PASSWORD"
	fi	
fi

echo "app:$MAIL_PASSWORD:$PUID:$PGID::/home/app::" > /etc/dovecot/users

cat > /etc/dovecot/conf.d/auth-passwdfile.conf.ext <<EOF
passdb {
  driver = passwd-file
  args = scheme=SHA512-CRYPT username_format=%u /etc/dovecot/users
}

userdb {
  driver = passwd-file
  args = username_format=%u /etc/dovecot/users

}
EOF

case $MBOXFORMAT in
	maildir)
		LOCATION="$MBOXFORMAT:~/Maildir"
		if [[ ! -d /home/app/Maildir ]]
		 then
			mkdir /home/app/Maildir
		fi
	;;
	sdbox|mdbox)
		LOCATION="$MBOXFORMAT:~/dbox"
		echo "mail_attachment_dir = ~/attachments" > /etc/dovecot/conf.d/11-dbox_options.conf
		echo "mail_attachment_min_size = 128k" >> /etc/dovecot/conf.d/11-dbox_options.conf
		echo "mail_attachment_fs = sis posix" >> /etc/dovecot/conf.d/11-dbox_options.conf
		echo "mail_attachment_hash = %{sha512}" >> /etc/dovecot/conf.d/11-dbox_options.conf
	;;
	*)
		echo "Unsupported MBOXFORMAT chosen ($MBOXFORMAT). Use maildir, sdbox or mdbox"
		exit 1
	;;
esac

echo "mail_location = $LOCATION" > /etc/dovecot/conf.d/11-mail-location.conf

chown -R app:app /home/app
