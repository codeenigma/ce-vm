# How to contribute

While this is originally an internal tool, contributions are more than welcome.

## Feature requests

Before spending hours on a patch, make sure to open an issue, explaining
what the feature you want to add is and how you plan to implement it.
We're happy to take feature requests in considerations, 
but have also some priorities of ours, so don't be offended if we reject it.
Keep in mind that:
1. There are other projects out there that might already cover your needs (https://www.drupalvm.com/, https://puphpet.com/, https://github.com/wodby/docker4drupal)
2. You can fork this project and bend it to your needs.

## Pull requests

Please make any pull requests against the major version branch (1.x currently),
not against master directly.
The master branch is considered the *stable* branch and should only
contain changes already merged into the major version branch
(keep in mind this is alpha though, so "stable" is whish more than anything)

## Release strategy - tagging

We try to stick with semantic versioning, (hence the major version branch).
- tag 1.1.1 > 1.1.1 : bugfix, minor amend
- tag 1.1.1 > 1.2.1 : new feature, backward compatible
- tag 1.1.1 > 2.1.1 : any change breaking backward compatibility
Is considered non-backward compatible any change that means the main Vagrantfile
from a given major version would stop working with the given changes.

## Documentation changes

Trivial documentation amends, provided they do apply to current version,
do not need to be tagged and can be made directly into the current major branch.
