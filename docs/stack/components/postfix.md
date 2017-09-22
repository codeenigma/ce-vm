
[http://www.postfix.org](http://www.postfix.org)

## Email management
No emails are actually ever sent to avoid any potential leaks and errors 
that could affect actual users.
Instead all emails, including system/root ones, are re-routed to the vagrant user.

How emails are then treated depends on the value of `mail_delivery` variable in 
your config file. It can take one of the following values:

### host
This is the default behaviour. All emails are stored as .eml files in a
ce-vm/var/$vm/Maildir folder, accessible from your host.
You can then conveniently open then in the destop mail client of your choice.

### local
Email adopts the standard Linux behaviour, and is only accessible from the guest,
using the `mail` command. This is mostly ony useful if you want to stick to the 
command line and/or manipulate the mailq in some manner.

### discard
Email is sent directly to /dev/null, thus non-accessible. 
Use this if your app generates a large amount of mail you don't need and
want to save disk space.

## Why no mail interface ?

A lot of similar stacks includes some web-based interceptors, 
eg [MailHog](https://github.com/mailhog/MailHog) or [MailCatcher](https://mailcatcher.me).

However, intercepting emails directly at the Postfix level presents two main
advantages over such solutions.

**1. Accurate rendering:** You don't have to rely on web based HTML rendering. 
Wondering how your nicely crafted newsletter is going to look in Outlook or 
Thunderbird ?
Just check using the actual sofware.

**2. System-wide:** No per application settings, no further configuration, 
no corner cases missed. Email will behave the same for cron jobs, 
PHP, python or NodeJS apps.