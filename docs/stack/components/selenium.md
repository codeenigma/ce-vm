
[http://www.seleniumhq.org](http://www.seleniumhq.org)

## Selenium server configuration
Setup is based on the 2.x serie of the "Selenium Standalone Server", installed as 
a system.d service, and ran by the "vagrant" user to avoid permissions issues.
You can start/stop it as any other services, using:

```
sudo service selenium stop
sudo service selenium start
```

The java jar itself will listen on the default port 4444.

## WebDriver
We currently use Firefox as the browser, using the web driver built-in selenium. 
To use Selenium with Behat/Mink, you will need to `composer require behat/mink-selenium2-driver`
and to add something similar to

```
  extensions:
    Behat\MinkExtension:
      selenium2: 
        capabilities: {"browser": "firefox", "version": "52"}
```

in your behat.yml file.

## Display manager
You can choose between two display managers to run your tests, set by 
the `selenium_display_manager` variable.

### XVFB
This is a light "headless" display manager, commonly used to run tests on servers.

### VNC
Offers an alternative approach to the standard XVFB method, allowing you to 
visually "see" the tests running in the browser, 
which can be very useful to understand failures.

It uses [TightVNC](https://www.tightvnc.com) as the server, 
and you should be able to use any VNC-compatible client on your host (eg. the Mac OS built-in one).

1. Open vnc://app-vm.codeenigma.com:5999 in your VNC client (password is "vagrant").
2. Run your tests - from either an ssh session in the VM or the xterminal within the remote desktop - and you should see Firefox actually perform the steps.
