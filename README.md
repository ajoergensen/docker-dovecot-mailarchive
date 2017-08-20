Dovecot (for mailarchhive)
==========================

Dovecot configured with one user (app), great for archiving mails. 

As it is supposed (for now at least) to be accessed locally or via a ssh tunnel, SSL/TLS is not used.

### Usage

 `docker run --rm --name mailarchive -e MBOXFORMAT=dbox -e "MAILPASSWORD={SHA512-CRYPT}$6$/LQkGPokW$Htf33uIYq6x9o7XCiVhNbA7IM4cjWjSAnY/tJyroy.suypFnIFkq2S3EnZV0pjbCh41.sLGsbljcNb0C3ZFH9/" ajoergensen/dovecot-mailarchive`

### Environment

- `MAIL_PASSWORD`: The password to use for logging into the IMAP4 server as user app
- `MBOXFORMAT`: The format to store the mails in, defaults to Maildir

#### Password

A note on the password. If you supply a clear text password it will be encrypted before adding it to the user database, but it will be available in clear text form in the container's environment.

I recommend using the encrypted form of the password in the environment.

On Linux, use `mkpasswd` to encrypt the password: `mkpasswd -m sha-512` then prefix the hashed string with the selected password hashing algorithm, in this case `{SHA512-CRYPT}`

For more information about supported password schemes, go to [Dovecot's documentation](https://wiki2.dovecot.org/Authentication/PasswordSchemes)

#### Mailbox formats

[Dovecot supports][mboxes] various mailbox formats, I've chosen to support Maildir and dbox (the container will fail if you chose something else.

 - `maildir`: Maildir format. Mails are stored in /home/app/Maildir
 - `sdbox`: Dbox format, one message per file. Mails are stored in /home/app/dbox
 - `mdbox`: Dbox format, multiple messages per file. Mails are stored in /home/app/dbox

[mboxes]: https://wiki2.dovecot.org/MailboxFormat

### Volumes

- `/home/app`: The app user's home directory, used to store the mail
